# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  enable_coverage :branch
  SimpleCov.minimum_coverage line: 98, branch: 96
  SimpleCov.refuse_coverage_drop :line, :branch
end
SimpleCov.command_name "unit"

require "logger"
require "rails"
require "pry-byebug"
require "active_support/core_ext"
require "swagcov"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.syntax = :expect
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.warnings = true
end
