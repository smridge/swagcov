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

    def ignore_path? path, verb:
      ignore_all_path_actions = ignored_regex&.match?(path)

      ignored_verbs = ignored_config&.find { |config| config[path] }

      return ignore_all_path_actions unless ignored_verbs.is_a?(::Hash)

      ignored_verbs.values.flatten.map(&:downcase).any?(verb.downcase)
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
      @ignored_regex ||= path_config_regex(ignored_config)
    end

    def ignored_config
      @ignored_config ||= dotfile.dig("routes", "paths", "ignore")
    end

    def only_regex
      @only_regex ||= path_config_regex(dotfile.dig("routes", "paths", "only"))
    end

    def path_config_regex path_config
      return unless path_config

      config =
        path_config.map do |path|
          if path.is_a?(::Hash)
            "^#{path.keys.first}$"
          else
            path.first == "^" ? path : "^#{path}$"
          end
        end

      /#{config.join('|')}/
    end

    def valid?
      dotfile && doc_paths
    end
  end
end
