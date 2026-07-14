class App::Services::Faqs < App::Services::Base
  def model; Faq; end

  def self.fields
    { save: [:category, :question, :answer] }
  end
end
