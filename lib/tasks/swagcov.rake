# frozen_string_literal: true

desc "Check OpenAPI documentation coverage for Rails Route endpoints"
task swagcov: :environment do
  exit Swagcov::Command::ReportCoverage.new.run
end
