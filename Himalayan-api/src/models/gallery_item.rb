class App::Models::GalleryItem < Sequel::Model
  def validate
    super
    validates_presence [:title]
  end
end
