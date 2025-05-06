# frozen_string_literal: true

namespace :swagcov do
  desc "Generate optional .swagcov_todo.yml config file acting as a TODO list"
  task generate_todo: :environment do
    exit Swagcov::Command::GenerateTodoFile.new.run
  end
end
