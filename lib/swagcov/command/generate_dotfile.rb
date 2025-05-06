# frozen_string_literal: true

module Swagcov
  module Command
    class GenerateDotfile
      attr_reader :dotfile

      def initialize basename: ::Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME
        @dotfile = ::Swagcov.project_root.join(basename)
      end

      def run
        if ::File.exist?(@dotfile)
          $stdout.puts "#{@dotfile.basename} already exists at #{@dotfile.dirname}"
          return ::Swagcov::STATUS_ERROR
        end

        ::File.write(
          dotfile,
          <<~YAML
            ## Required field:
            # List your OpenAPI documentation file(s) (accepts json or yaml)
            docs:
              paths:
                - swagger.yaml
                - swagger.json

            ## Optional fields:
            # routes:
            #   paths:
            #     only:
            #       - ^/v2 # only track v2 endpoints
            #     ignore:
            #       - /v2/users # do not track certain endpoints
            #       - /v2/users/:id: # ignore only certain actions (verbs)
            #         - GET
          YAML
        )

        $stdout.puts "created #{@dotfile.basename} at #{@dotfile.dirname}"

        ::Swagcov::STATUS_SUCCESS
      end
    end
  end
end
