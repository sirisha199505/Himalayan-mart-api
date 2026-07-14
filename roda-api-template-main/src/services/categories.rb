class App::Services::Categories < App::Services::Base
  def model; Category; end

  def self.fields
    { save: [:slug, :name, :tagline, :description, :image, :icon, :count, :featured] }
  end
end
