# frozen_string_literal: true

namespace :swagcov do
  desc "create config file"
  task install: :environment do
    exit Swagcov::Command::GenerateDotfile.new.run
  end
end
