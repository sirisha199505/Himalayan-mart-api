class App::Services::CaseStudies < App::Services::Base
  def model; CaseStudy; end

  def self.fields
    { save: [:slug, :title, :client, :location, :category, :cover, :summary,
             :requirement, :solution, :outcome, :challenges, :furniture_used,
             :gallery, :stats, :images] }
  end
end
