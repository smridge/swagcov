# frozen_string_literal: true

namespace :swagcov do
  desc "create config file"
  task install: :environment do
    Swagcov::Install.new.generate_dotfile
  end
end
