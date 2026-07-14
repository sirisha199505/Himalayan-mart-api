class App::Services::Seos < App::Services::Base
  def model; SeoEntry; end

  def self.fields
    { save: [:page, :title, :description, :keywords] }
  end
end
