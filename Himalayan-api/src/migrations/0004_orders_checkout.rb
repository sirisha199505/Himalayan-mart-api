Sequel.migration do
  change do
    # Extend the orders table so a guest checkout / Razorpay payment can be
    # persisted. All columns are additive and nullable — the existing
    # code/customer/items/total/status/date columns keep their meaning
    # (customer = buyer name, items = line count, total = rupees) so the
    # admin orders view is unaffected.
    alter_table(:orders) do
      add_column :email,             String
      add_column :phone,             String
      add_column :address,           String, text: true
      add_column :city,              String
      add_column :state,             String
      add_column :pincode,           String

      # [{ slug, name, price, qty }] priced from the DB at checkout time.
      add_column :line_items,        :jsonb, default: '[]'

      add_column :amount,            Integer            # payable amount in paise
      add_column :currency,          String, default: 'INR'
      add_column :payment_method,    String             # 'razorpay' | 'cod'
      add_column :payment_status,    String             # 'created' | 'paid' | 'failed' | 'cod_pending'

      add_column :razorpay_order_id,   String
      add_column :razorpay_payment_id, String
      add_column :razorpay_signature,  String
    end
  end
end
