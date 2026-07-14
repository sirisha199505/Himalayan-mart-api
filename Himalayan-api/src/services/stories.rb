class App::Services::Stories < App::Services::Base
  def model; Story; end

  def self.fields
    { save: [:slug, :title, :kicker, :excerpt, :cover, :body, :images] }
  end
end
