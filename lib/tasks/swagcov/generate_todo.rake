# frozen_string_literal: true

namespace :swagcov do
  desc "generate todo config file"
  task generate_todo: :environment do
    exit Swagcov::Command::GenerateTodoFile.new.run
  end
end
