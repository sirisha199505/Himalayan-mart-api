require 'openssl'
require 'securerandom'

# Public (guest) checkout + Razorpay payment.
#
# Security: the browser never sets the payable amount. Every order is priced
# on the server from the DB `products` table by slug. Razorpay amounts are in
# paise; we also keep a rupee `total` for the admin view.
class App::Services::Checkout < App::Services::Base
  RAZORPAY_BASE = 'https://api.razorpay.com/v1'.freeze

  # POST /api/checkout/create-order
  # params[:data] => { items: [{slug, qty}], customer: {name,email,phone,address,city,state,pincode} }
  def create_order
    cust = customer_data!
    line_items, total = price_items!  # total in rupees
    amount = total * 100              # paise

    order = build_order(cust, line_items, total, amount,
                        payment_method: 'razorpay', payment_status: 'created')
    return_errors!(order.errors, 400) unless order.save
    order.update(code: gen_code(order.id))

    status, body = razorpay_post('/orders', {
      amount: amount, currency: 'INR', receipt: order.code,
      notes: { order_code: order.code }
    })

    unless status && status >= 200 && status < 300 && body && body['id']
      order.update(payment_status: 'failed')
      msg = (body && body.dig('error', 'description')) ||
            'Payment gateway error. Please check the store payment configuration.'
      return_errors!(msg, 502)
    end

    order.update(razorpay_order_id: body['id'])

    return_success(
      order_code: order.code,
      token: order_token(order.code),
      key_id: App.razorpay_key_id,
      razorpay_order_id: body['id'],
      amount: amount,
      currency: 'INR',
      prefill: { name: cust[:customer], email: cust[:email], contact: cust[:phone] }
    )
  end

  # POST /api/checkout/verify
  # params[:data] => { razorpay_order_id, razorpay_payment_id, razorpay_signature }
  def verify
    rzp_order_id = params[:razorpay_order_id]
    payment_id   = params[:razorpay_payment_id]
    signature    = params[:razorpay_signature]
    check_presence!(:razorpay_order_id, :razorpay_payment_id, :razorpay_signature)

    order = Order.first(razorpay_order_id: rzp_order_id)
    return_errors!('Order not found', 404) unless order

    expected = OpenSSL::HMAC.hexdigest(
      'SHA256', App.razorpay_key_secret.to_s, "#{rzp_order_id}|#{payment_id}"
    )

    unless Rack::Utils.secure_compare(expected, signature.to_s)
      order.update(payment_status: 'failed',
                   razorpay_payment_id: payment_id,
                   razorpay_signature: signature)
      return_errors!('Payment signature verification failed', 400)
    end

    order.update(payment_status: 'paid', status: 'Processing',
                 razorpay_payment_id: payment_id, razorpay_signature: signature)
    upsert_customer(order)
    send_order_emails(order)

    return_success(order_code: order.code, token: order_token(order.code), payment_status: 'paid')
  end

  # GET /api/checkout/order?code=…&token=…  — public order detail lookup.
  # The token is an HMAC of the code, handed to the buyer at checkout, so only
  # someone with the confirmation link can view the order (no login needed).
  def show
    code  = qs[:code].to_s
    token = qs[:token].to_s
    order = Order.first(code: code)
    return_errors!('Order not found', 404) unless order
    unless Rack::Utils.secure_compare(order_token(code), token)
      return_errors!('Invalid or missing order token', 403)
    end
    return_success(public_order(order))
  end

  # POST /api/checkout/cod — place a Cash-on-Delivery order (no gateway).
  def place_cod
    cust = customer_data!
    line_items, total = price_items!
    amount = total * 100

    order = build_order(cust, line_items, total, amount,
                        payment_method: 'cod', payment_status: 'cod_pending',
                        status: 'Processing')
    return_errors!(order.errors, 400) unless order.save
    order.update(code: gen_code(order.id))
    upsert_customer(order)
    send_order_emails(order)

    return_success(order_code: order.code, token: order_token(order.code), payment_method: 'cod')
  end

  private

  # Stateless per-order token (no DB column needed). Unguessable without the
  # server secret, so it gates public order lookup.
  def order_token(code)
    OpenSSL::HMAC.hexdigest('SHA256', ENV['JWT_SECRET'].to_s, "order:#{code}")
  end

  # Whitelisted, buyer-facing view of an order.
  def public_order(o)
    li = o.line_items
    li = JSON.parse(li) if li.is_a?(String)
    {
      code: o.code, status: o.status, date: o.date,
      payment_method: o.payment_method, payment_status: o.payment_status,
      total: o.total, amount: o.amount, currency: o.currency, items: o.items,
      line_items: li,
      customer: {
        name: o.customer, phone: o.phone, email: o.email,
        address: o.address, city: o.city, state: o.state, pincode: o.pincode
      }
    }
  end

  # Validate + normalize the buyer details from params[:customer].
  def customer_data!
    c = params[:customer] || {}
    name    = c[:name].to_s.strip
    phone   = c[:phone].to_s.strip
    address = c[:address].to_s.strip
    if name.empty? || phone.empty? || address.empty?
      return_errors!({ customer: 'Name, phone and address are required' }, 400)
    end
    {
      customer: name, email: c[:email].to_s.strip, phone: phone,
      address: address, city: c[:city].to_s.strip,
      state: c[:state].to_s.strip, pincode: c[:pincode].to_s.strip
    }
  end

  # Price the cart from the DB. Returns [line_items(Array), total(Integer ₹)].
  def price_items!
    raw = params[:items]
    return_errors!({ items: 'Cart is empty' }, 400) if raw.nil? || raw.empty?

    line_items = []
    total = 0
    raw.each do |it|
      slug = it[:slug].to_s
      qty  = it[:qty].to_i
      qty  = 1 if qty < 1
      product = Product.first(slug: slug)
      return_errors!({ items: "Unknown product: #{slug}" }, 400) unless product
      return_errors!({ items: "Out of stock: #{product.name}" }, 400) unless product.in_stock
      return_errors!({ items: "Not available for online purchase: #{product.name}" }, 400) if product.price.to_i <= 0

      line_total = product.price.to_i * qty
      total += line_total
      line_items << { slug: product.slug, name: product.name, price: product.price.to_i, qty: qty }
    end

    [line_items, total]
  end

  def build_order(cust, line_items, total, amount, attrs)
    Order.new({
      customer: cust[:customer], email: cust[:email], phone: cust[:phone],
      address: cust[:address], city: cust[:city], state: cust[:state], pincode: cust[:pincode],
      line_items: line_items, items: line_items.sum { |li| li[:qty] },
      total: total, amount: amount, currency: 'INR',
      date: Time.now.strftime('%Y-%m-%d')
    }.merge(attrs))
  end

  # Sequential, human-friendly order number derived from the (unique,
  # auto-incrementing) row id — so codes never collide and read in order.
  def gen_code(id)
    "HFM-#{1000 + id.to_i}"
  end

  # Maintain the admin `customers` aggregate (by email when present, else name).
  def upsert_customer(order)
    return if order.email.to_s.empty? && order.customer.to_s.empty?
    existing = order.email.to_s.empty? ? Customer.first(name: order.customer)
                                       : Customer.first(email: order.email)
    if existing
      existing.update(
        orders: existing.orders.to_i + 1,
        spent: existing.spent.to_i + order.total.to_i
      )
    else
      Customer.create(
        name: order.customer, email: order.email, city: order.city,
        orders: 1, spent: order.total.to_i,
        since: Time.now.strftime('%Y-%m-%d')
      )
    end
  rescue => e
    App.logger.error("customer upsert failed: #{e.message}")
  end

  def razorpay_post(path, payload)
    resp = HTTPX.plugin(:basic_auth)
                .basic_auth(App.razorpay_key_id.to_s, App.razorpay_key_secret.to_s)
                .post("#{RAZORPAY_BASE}#{path}", json: payload)
    if resp.respond_to?(:error) && resp.error
      App.logger.error("Razorpay request failed: #{resp.error.message}")
      return [nil, nil]
    end
    body = begin
      JSON.parse(resp.body.to_s)
    rescue StandardError
      nil
    end
    [resp.status, body]
  end

  # ── Order confirmation emails ───────────────────────────────────────────
  # On a confirmed order (online payment verified, or COD placed) send a
  # receipt to the customer and a notification to the store owner. Never
  # raises: a mail failure must not roll back an order that is already saved.
  def send_order_emails(order)
    buyer = order.email.to_s.strip
    unless buyer.empty?
      deliver_mail(buyer, "Your Himalayan Mart order #{order.code}",
                   customer_email_html(order))
    end

    owner = owner_email
    unless owner.empty?
      deliver_mail(owner, "New order #{order.code} — #{order.customer}",
                   owner_email_html(order))
    end
  rescue => e
    App.logger.error("order email failed for #{order.code}: #{e.message}")
  end

  # Owner / notification recipient: store settings email first, then env
  # overrides, so a notice still goes out even if settings are blank.
  def owner_email
    [Setting.first&.email, ENV['ORDER_NOTIFICATION_EMAIL'], ENV['EMAIL_FROM']]
      .map { |c| c.to_s.strip }
      .find { |c| !c.empty? }
      .to_s
  end

  def deliver_mail(to_addr, subject_line, html_body)
    Mail.new do
      from    ENV.fetch('EMAIL_FROM', 'noreply@himalayanfurnituremart.in')
      to      to_addr
      subject subject_line
      html_part do
        content_type 'text/html; charset=UTF-8'
        body html_body
      end
    end.deliver!
  end

  def payment_label(order)
    case order.payment_method
    when 'cod'      then 'Cash on Delivery'
    when 'razorpay' then 'Paid Online (Razorpay)'
    else order.payment_method.to_s
    end
  end

  # Shared items table + total + delivery block, used in both emails.
  def order_summary_html(order)
    li = order.line_items
    li = JSON.parse(li) if li.is_a?(String)
    rows = (li || []).map do |it|
      it    = it.transform_keys(&:to_s)
      qty   = it['qty'].to_i
      price = it['price'].to_i
      "<tr><td style='padding:6px 0;'>#{it['name']} &times; #{qty}</td>" \
      "<td style='padding:6px 0;text-align:right;'>&#8377;#{price * qty}</td></tr>"
    end.join
    address = [order.address, order.city, order.state, order.pincode]
              .map { |x| x.to_s.strip }.reject(&:empty?).join(', ')
    <<-HTML
      <table style="width:100%;border-collapse:collapse;font-size:14px;color:#1c2b2e;">
        #{rows}
        <tr>
          <td style="padding:10px 0 0;border-top:1px solid #e4dfd4;font-weight:bold;">Total</td>
          <td style="padding:10px 0 0;border-top:1px solid #e4dfd4;text-align:right;font-weight:bold;">&#8377;#{order.total}</td>
        </tr>
      </table>
      <p style="font-size:14px;color:#47585b;line-height:1.6;">
        <strong>Payment:</strong> #{payment_label(order)} (#{order.payment_status})<br/>
        <strong>Deliver to:</strong> #{order.customer}, #{order.phone}<br/>
        #{address}
      </p>
    HTML
  end

  def customer_email_html(order)
    <<-HTML
      <html><body style="font-family:Arial,Helvetica,sans-serif;color:#1c2b2e;max-width:560px;">
        <h2 style="color:#2e6e6a;">Thank you for your order!</h2>
        <p>Hi #{order.customer}, we've received your order <strong>#{order.code}</strong>. Here are the details:</p>
        #{order_summary_html(order)}
        <p style="font-size:14px;color:#47585b;">We'll keep you updated as your order is processed. Questions? Just reply to this email.</p>
        <p style="font-size:13px;color:#8a8a8a;">Himalayan Furniture Mart</p>
      </body></html>
    HTML
  end

  def owner_email_html(order)
    <<-HTML
      <html><body style="font-family:Arial,Helvetica,sans-serif;color:#1c2b2e;max-width:560px;">
        <h2 style="color:#2e6e6a;">New order received — #{order.code}</h2>
        <p>A new order has been placed by <strong>#{order.customer}</strong> (#{order.email}, #{order.phone}).</p>
        #{order_summary_html(order)}
        <p style="font-size:13px;color:#8a8a8a;">Automated notification from your store.</p>
      </body></html>
    HTML
  end
end
