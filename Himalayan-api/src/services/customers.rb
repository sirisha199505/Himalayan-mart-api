class App::Services::Customers < App::Services::Base
  def model; Customer; end

  def self.fields
    { save: [:name, :email, :city, :orders, :spent, :since] }
  end
end
