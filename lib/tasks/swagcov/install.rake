# frozen_string_literal: true

namespace :swagcov do
  desc "create config file"
  task install: :environment do
    exit Swagcov::Install.new.run
  end
end
