# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in subject_spotter.gemspec
gemspec

gem "rake", "~> 13.0"

gem "rspec", "~> 3.0"

gem "rubocop", "~> 1.21"

group :test do
  gem "fuubar"

  gem "pry"

  gem "simplecov",      require: false
  gem "simplecov-lcov", require: false

  gem "vcr"
  gem "webmock"
end
