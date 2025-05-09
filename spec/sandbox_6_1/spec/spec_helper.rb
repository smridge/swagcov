# frozen_string_literal: true

require "simplecov"

SimpleCov.root(File.expand_path("../../..", __dir__))
SimpleCov.start do
  add_filter "/spec/"
  enable_coverage :branch
end
SimpleCov.command_name "e2e:sandbox_6_1"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
Dir["../sandbox_support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.use_active_record = false
  config.filter_rails_from_backtrace!
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before { allow($stdout).to receive(:puts) } # suppress output in specs
end
