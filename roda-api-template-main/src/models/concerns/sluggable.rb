module Sluggable
  # Auto-generate a URL slug from name/title when one isn't supplied.
  def before_validation
    if respond_to?(:slug) && (slug.nil? || slug.to_s.strip.empty?)
      source = (respond_to?(:name) && name) || (respond_to?(:title) && title)
      self.slug = generate_slug(source) if source
    end
    super
  end

  def generate_slug(source)
    base = source.to_s.downcase.strip
             .gsub(/[^a-z0-9\s-]/, '')
             .gsub(/[\s-]+/, '-')
             .gsub(/^-+|-+$/, '')
    base = "item" if base.empty?
    candidate = base
    n = 1
    while self.class.where(slug: candidate).exclude(id: id).count > 0
      n += 1
      candidate = "#{base}-#{n}"
    end
    candidate
  end
end
