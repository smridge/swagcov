# frozen_string_literal: true

module Swagcov
  class BadConfigurationError < RuntimeError
  end

  class Dotfile
    def initialize
      @dotfile = YAML.load_file(Rails.root.join(".swagcov.yml"))
      raise BadConfigurationError, "Invalid .swagcov.yml" unless valid?
    end

    def ignore_path? path
      ignored_regex&.match?(path) || (only_regex && !only_regex.match?(path))
    end

    def doc_paths
      dotfile.dig("docs", "paths")
    end

    private

    attr_reader :dotfile

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
