class App::Services::Blogs < App::Services::Base
  def model; BlogPost; end

  def self.fields
    { save: [:slug, :title, :excerpt, :category, :cover, :author, :author_role,
             :date, :tags, :content, :images] }
  end
end
