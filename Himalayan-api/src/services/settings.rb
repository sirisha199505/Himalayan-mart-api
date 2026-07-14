class App::Services::Settings < App::Services::Base
  def model; Setting; end

  # Settings is a singleton row.
  def current
    row = Setting.first || Setting.create(store_name: 'Himalayan Furniture Mart')
    return_success(row.to_pos)
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
