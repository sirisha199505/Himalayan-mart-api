#!/usr/bin/env ruby
# Seeds / upserts an admin user. Usage:
#   ruby scripts/seed_admin.rb "Full Name" email@example.com password ROLE_INT
require 'bundler/setup'
Bundler.require(:default)
require './src/app'
App.load!

full_name = ARGV[0] || 'Sirisha'
email     = ARGV[1] || 'admin@himalayanfurnituremart.in'
password  = ARGV[2] || 'admin123'
role      = (ARGV[3] || 1).to_i

user = App::Models::User.find(email: email) || App::Models::User.new(email: email)
user.full_name = full_name
user.password  = password
user.role      = role
user.active    = true
if user.save
  puts "OK: #{user.email} (id=#{user.id}, role=#{user.role})"
else
  puts "FAILED: #{user.errors.inspect}"
  exit 1
end
