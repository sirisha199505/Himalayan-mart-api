FROM ruby:3.4.1

RUN apt-get update && apt-get -y install libpq-dev gcc

WORKDIR /app

# Run in production mode (skips the dev-only file watcher, quieter logs)
ENV RACK_ENV=production

# The Roda app lives in the Himalayan-api/ subfolder of this repo.
COPY Himalayan-api/Gemfile* ./

RUN bundle install

COPY Himalayan-api/ ./

# Bind to the port the host assigns (Render/Heroku set $PORT); default 8080 locally.
CMD bundle exec puma -p ${PORT:-8080} -b tcp://0.0.0.0
