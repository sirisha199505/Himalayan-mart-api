#!/usr/bin/env bash
# Boot the API on PORT (default 9292). Handles the ruby-version + env quirks.
set -e
cd "$(dirname "$0")/.."
export RBENV_VERSION=3.4.6
set -a; source .env; set +a
PORT="${1:-9292}"
exec bundle exec ruby -e "require 'puma/cli'; Puma::CLI.new(['-p','${PORT}','config.ru']).run"
