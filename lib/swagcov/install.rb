# frozen_string_literal: true

module Swagcov
  class Install
    attr_reader :dotfile

    def initialize pathname: ::Rails.root.join(::Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME).to_s
      @dotfile = pathname
    end

    def generate_dotfile
      if ::File.exist?(dotfile)
        $stdout.puts "#{dotfile} already exists"
        return
      end

      ::File.write(
        dotfile,
        <<~YAML
          ## Required field:
          # List your OpenAPI documentation files
          docs:
            paths:
              - swagger.yaml

          ## Optional fields:
          # routes:
          #   paths:
          #     only:
          #       - ^/v2 # only track v2 endpoints
          #     ignore:
          #       - /v2/users # do not track certain endpoints
        YAML
      )

      $stdout.puts "created #{::Swagcov::Dotfile::DEFAULT_CONFIG_FILE_NAME}"
    end
  end
end
