class App::Models::Category < Sequel::Model
  include Sluggable

  def validate
    super
    validates_presence [:name]
    validates_unique(:slug) { |ds| ds.exclude(slug: nil) }
  end
end
