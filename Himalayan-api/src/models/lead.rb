class App::Models::Lead < Sequel::Model
  def validate
    super
    validates_presence [:name]
  end
end
