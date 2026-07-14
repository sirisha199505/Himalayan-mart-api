class App::Models::Product < Sequel::Model
  include Sluggable

  def validate
    super
    validates_presence [:name]
    validates_unique(:slug) { |ds| ds.exclude(slug: nil) }
  end
end
