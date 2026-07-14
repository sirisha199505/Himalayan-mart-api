require 'bundler'
require 'open-uri'
require 'csv'
Rack::Utils # Patch

# Load environment variables from a local .env file (no dotenv gem needed) so
# the app boots the same way regardless of how it's started (puma, rackup, etc.)
env_file = File.expand_path('.env', __dir__)
if File.exist?(env_file)
  File.foreach(env_file) do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    key, _, value = line.partition('=')
    key = key.strip
    value = value.strip.gsub(/\A["']|["']\z/, '')
    ENV[key] ||= value unless key.empty?
  end
end

require './src/app'

Bundler.require(:default, App.env)


use Rack::Cors do

  allow do
    origins '*'
    resource '*', :headers => :any, :methods => [:get, :post, :delete, :put, :patch, :options, :head]
  end
end

App.load!

run App::Routes

if App.development?
  Listen.to(File.expand_path(File.dirname(__FILE__)), only: %r{.rb$}) do |added, modified, removed|
    files_to_reload = added + modified
    
    App.logger.info("Reloading: #{files_to_reload.join(', ')}")
    
    # Handle route file specially to ensure proper reloading
    if files_to_reload.any? { |f| f.include?('routes.rb') }
      App.logger.info("Routes file changed, consider restarting the server for full effect")
      # Optionally implement more sophisticated routes reloading here
    end
    
    # Reload all changed files
    files_to_reload.each do |f|
      begin
        load(f)
        App.logger.info("Successfully reloaded: #{f}")
      rescue => e
        App.logger.error("Error reloading #{f}: #{e.message}")
        App.logger.error(e.backtrace.join("\n"))
      end
    end
  end.start
end
