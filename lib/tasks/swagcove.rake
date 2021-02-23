# frozen_string_literal: true

desc "check documentation coverage for endpoints"
task swagcov: :environment do
  Swagcov::Coverage.new.report
end
