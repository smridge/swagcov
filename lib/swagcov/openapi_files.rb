# frozen_string_literal: true

module Swagcov
  class OpenapiFiles
    def initialize filepaths:
      @filepaths = filepaths
      @openapi_paths = load_yamls
      @openapi_path_keys = @openapi_paths.keys
    end

    def find_response_keys path:, route_verb:
      # replace :id with {id}
      regex = ::Regexp.new("^#{path.gsub(%r{:[^/]+}, '\\{[^/]+\\}')}?$")

      matching_paths_key = @openapi_path_keys.grep(regex).first
      matching_request_method_key = @openapi_paths.dig(matching_paths_key, route_verb.downcase)

      matching_request_method_key["responses"].keys.map(&:to_s).sort if matching_request_method_key
    end

    private

    def load_yamls
      ::Dir.glob(@filepaths).reduce({}) do |hash, filepath|
        hash.merge(load_yaml(filepath))
      end
    end

    def load_yaml filepath
      ::YAML.load_file(filepath)["paths"] # loads yaml or json
    rescue ::Psych::SyntaxError, ::JSON::ParserError
      raise ::Swagcov::Errors::BadConfiguration, "Malformed openapi file (#{filepath})"
    end
  end
end
