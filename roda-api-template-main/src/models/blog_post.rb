class App::Models::BlogPost < Sequel::Model
  include Sluggable

  def validate
    super
    validates_presence [:title]
    validates_unique(:slug) { |ds| ds.exclude(slug: nil) }
  end
end
