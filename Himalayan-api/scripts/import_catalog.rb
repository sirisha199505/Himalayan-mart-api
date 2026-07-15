#!/usr/bin/env ruby
# Import the storefront catalog (exported by the UI's scripts/export-catalog.mjs)
# into the DB `products` table so checkout can price orders server-side.
#
# Idempotent: upserts by slug. Usage:
#   DB_URL="..." RBENV_VERSION=3.4.1 bundle exec ruby scripts/import_catalog.rb [path]
# Default path: scripts/catalog.json
require 'bundler/setup'
Bundler.require(:default)
require 'json'
require './src/app'
App.load!

path = ARGV[0] || File.join(App.root, 'scripts', 'catalog.json')
abort "Catalog file not found: #{path}" unless File.exist?(path)

rows = JSON.parse(File.read(path))
created = 0
updated = 0

rows.each do |r|
  attrs = r.transform_keys(&:to_sym)
  slug = attrs[:slug]
  next if slug.nil? || slug.empty?

  product = App::Models::Product.first(slug: slug)
  if product
    product.set(attrs)
    product.save_changes
    updated += 1
  else
    App::Models::Product.create(attrs)
    created += 1
  end
end

puts "Catalog import complete: #{created} created, #{updated} updated (#{rows.size} total)."
