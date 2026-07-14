class App::Services::GalleryItems < App::Services::Base
  def model; GalleryItem; end

  def self.fields
    { save: [:title, :category, :image, :span, :location, :images] }
  end
end
