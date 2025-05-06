# frozen_string_literal: true

namespace :swagcov do
  desc "Generate required .swagcov.yml config file"
  task install: :environment do
    exit Swagcov::Command::GenerateDotfile.new.run
  end
end
