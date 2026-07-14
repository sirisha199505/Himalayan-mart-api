class App::Services::Settings < App::Services::Base
  def model; Setting; end

  # Fields safe to expose on the public storefront (no auth required).
  PUBLIC_FIELDS = %w[store_name tagline phone email whatsapp
                     instagram facebook youtube city state hours extras].freeze

  # Settings is a singleton row.
  def current
    row = Setting.first || Setting.create(store_name: 'Himalayan Furniture Mart')
    return_success(row.to_pos)
  end

  # Public, whitelisted view of the store settings for the storefront.
  def public_info
    row = Setting.first || Setting.create(store_name: 'Himalayan Furniture Mart')
    return_success(row.to_pos.slice(*PUBLIC_FIELDS))
  end

  def save_current
    row = Setting.first || Setting.new
    data = data_for(:save)
    row.set_fields(data, data.keys)
    save(row)
  end

  def self.fields
    { save: [:store_name, :tagline, :phone, :email, :whatsapp,
             :instagram, :facebook, :youtube, :city, :state, :hours, :extras] }
  end
end
