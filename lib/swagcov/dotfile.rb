# frozen_string_literal: true

module Swagcov
  class Dotfile
    DEFAULT_CONFIG_FILE_NAME = ".swagcov.yml"

    def initialize pathname: ::Rails.root.join(DEFAULT_CONFIG_FILE_NAME)
      @dotfile = load_yaml(pathname)

      raise ::Swagcov::Errors::BadConfiguration, "Invalid config file (#{DEFAULT_CONFIG_FILE_NAME})" unless valid?

      @ignored_regex = path_config_regex(ignored_config)
      @only_regex = path_config_regex(only_config)
    end

    def ignore_path? path, verb:
      return false unless @ignored_config

      ignore_all_path_actions = @ignored_regex.match?(path)

      ignored_verbs = @ignored_config.find { |config| config[path] }

      return ignore_all_path_actions unless ignored_verbs.is_a?(::Hash)

      ignored_verbs.values.flatten.map(&:downcase).any?(verb.downcase)
    end

    def only_path_mismatch? path
      @only_config && !@only_regex.match?(path)
    end

    def docs_config
      @docs_config ||= dotfile.dig("docs", "paths")
    end

    def ignored_config
      @ignored_config ||= dotfile.dig("routes", "paths", "ignore")
    end

    def only_config
      @only_config ||= dotfile.dig("routes", "paths", "only")
    end

    private

    attr_reader :dotfile

    def load_yaml pathname
      unless pathname.exist?
        raise ::Swagcov::Errors::BadConfiguration, "Missing config file (#{DEFAULT_CONFIG_FILE_NAME})"
      end

      ::YAML.load_file(pathname)
    rescue Psych::SyntaxError
      raise ::Swagcov::Errors::BadConfiguration, "Malinformed config file (#{DEFAULT_CONFIG_FILE_NAME})"
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
      dotfile && docs_config
    end
  end
end
