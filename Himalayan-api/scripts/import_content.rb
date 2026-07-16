#!/usr/bin/env ruby
# Import storefront content (exported by the UI's scripts/export-content.mjs)
# into the DB. Sluggable entities upsert by slug; gallery/faqs (no slug) are
# replaced wholesale. Usage:
#   RBENV_VERSION=3.4.1 bundle exec ruby scripts/import_content.rb [names...]
# Default names: categories blogs case-studies stories gallery faqs
require 'bundler/setup'
Bundler.require(:default)
require 'json'
require './src/app'
App.load!
M = App::Models

# name => [model, strategy]
SPEC = {
  'categories'   => [M::Category,    :slug],
  'blogs'        => [M::BlogPost,    :slug],
  'case-studies' => [M::CaseStudy,   :slug],
  'stories'      => [M::Story,       :slug],
  'gallery'      => [M::GalleryItem, :replace],
  'faqs'         => [M::Faq,         :replace]
}.freeze

names = ARGV.empty? ? SPEC.keys : ARGV
names.each do |name|
  model, strategy = SPEC[name]
  abort "Unknown content set: #{name}" unless model
  path = File.join(App.root, 'scripts', "#{name}.json")
  next puts("skip #{name}: #{path} not found") unless File.exist?(path)
  rows = JSON.parse(File.read(path)).map { |r| r.transform_keys(&:to_sym) }

  if strategy == :replace
    deleted = model.dataset.delete
    rows.each { |attrs| model.create(attrs) }
    puts "#{name}: replaced (deleted #{deleted}, inserted #{rows.size})"
  else # upsert by slug
    created = updated = 0
    rows.each do |attrs|
      existing = model.first(slug: attrs[:slug])
      if existing
        existing.set(attrs); existing.save_changes; updated += 1
      else
        model.create(attrs); created += 1
      end
    end
    puts "#{name}: #{created} created, #{updated} updated (#{rows.size} total)"
  end
end
