# frozen_string_literal: true

desc "Check OpenAPI documentation coverage for Rails Route endpoints"
task swagcov: :environment do
  args = ARGV.drop(2) # Remove "swagcov" and "--" to ignore standard rake arguments
  Swagcov::Runner.new(args: args).run
end
