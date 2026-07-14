class App::Models::Faq < Sequel::Model
  def validate
    super
    validates_presence [:question]
  end
end
