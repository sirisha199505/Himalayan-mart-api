class App::Services::Orders < App::Services::Base
  def model; Order; end

  def self.fields
    { save: [:code, :customer, :items, :total, :status, :date,
             :email, :phone, :address, :city, :state, :pincode,
             :amount, :currency, :payment_method, :payment_status,
             :razorpay_order_id, :razorpay_payment_id, :razorpay_signature] }
  end
end
