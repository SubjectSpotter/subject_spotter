# frozen_string_literal: true

require_relative "support/simplecov_profile"
require_relative "support/vcr_profile"
require "pry"

require "subject_spotter"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.add_formatter "Fuubar"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require "vcr"
