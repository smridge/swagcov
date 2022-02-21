# frozen_string_literal: true

module Swagcov
  class BadConfigurationError < RuntimeError
  end

  class Dotfile
    DEFAULT_CONFIG_FILE_NAME = ".swagcov.yml"

    def initialize pathname: ::Rails.root.join(DEFAULT_CONFIG_FILE_NAME)
      @dotfile = load_yaml(pathname)

      raise BadConfigurationError, "Invalid config file (#{DEFAULT_CONFIG_FILE_NAME})" unless valid?
    end

    def ignore_path? path
      ignored_regex&.match?(path)
    end

    def only_path_mismatch? path
      only_regex && !only_regex.match?(path)
    end

    def doc_paths
      dotfile.dig("docs", "paths")
    end

    private

    attr_reader :dotfile

    def load_yaml pathname
      raise BadConfigurationError, "Missing config file (#{DEFAULT_CONFIG_FILE_NAME})" unless pathname.exist?

      YAML.load_file(pathname)
    rescue Psych::SyntaxError
      raise BadConfigurationError, "Malinformed config file (#{DEFAULT_CONFIG_FILE_NAME})"
    end

    def ignored_regex
      @ignored_regex ||= path_config_regex(dotfile.dig("routes", "paths", "ignore"))
    end

    def only_regex
      @only_regex ||= path_config_regex(dotfile.dig("routes", "paths", "only"))
    end

    def path_config_regex path_config
      return unless path_config

      config = path_config.map { |path| path.first == "^" ? path : "^#{path}$" }

      /#{config.join('|')}/
    end

    def valid?
      dotfile && doc_paths
    end
  end
end
