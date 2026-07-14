class App::Models::Customer < Sequel::Model
  def validate
    super
    validates_presence [:name]
  end
end
