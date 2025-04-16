# frozen_string_literal: true

desc "check documentation coverage for endpoints"
task swagcov: :environment do
  exit Swagcov::Command::ReportCoverage.new.run
end
