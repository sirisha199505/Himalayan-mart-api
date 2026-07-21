class App::Services::Locations < App::Services::Base
  def model; Location; end

  def self.fields
    { save: [:name, :address, :phone, :email, :map_url, :hours, :is_flagship] }
  end
end
