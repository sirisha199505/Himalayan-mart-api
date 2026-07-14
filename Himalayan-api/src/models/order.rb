class App::Models::Order < Sequel::Model
  def validate
    super
    validates_presence [:customer]
  end
end
