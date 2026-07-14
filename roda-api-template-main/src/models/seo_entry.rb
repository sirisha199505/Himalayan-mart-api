class App::Models::SeoEntry < Sequel::Model
  def validate
    super
    validates_presence [:page]
  end
end
