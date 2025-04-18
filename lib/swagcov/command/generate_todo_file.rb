# frozen_string_literal: true

module Swagcov
  module Command
    class GenerateTodoFile
      def initialize basename: ::Swagcov::Dotfile::TODO_CONFIG_FILE_NAME,
                     data: ::Swagcov::Coverage.new(dotfile: ::Swagcov::Dotfile.new(skip_todo: true)).collect[:uncovered]
        @dotfile = ::Swagcov.project_root.join(basename)
        @data = data
      end

      def run
        ::File.write(
          @dotfile,
          <<~YAML
            # This configuration was auto generated
            # The intent is to remove these route configurations as documentation is added
            #{routes_yaml}
          YAML
        )

        $stdout.puts "created #{@dotfile.basename} at #{@dotfile.dirname}"

        ::Swagcov::STATUS_SUCCESS
      end

      private

      def routes_yaml
        return if routes.empty?

        {
          "routes" => {
            "paths" => {
              "ignore" => routes
            }
          }
        }.to_yaml.strip
      end

      def routes
        hash = {}

        @data.each do |route|
          hash[route[:path]] ? hash[route[:path]] << route[:verb] : hash[route[:path]] = [route[:verb]]
        end

        @routes ||= hash.map { |key, value| { key => value } }
      end
    end
  end
end
