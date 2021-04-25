# frozen_string_literal: true

module Swagcov
  class Dotfile
    def initialize
      @dotfile = YAML.load_file(Rails.root.join(".swagcov.yml"))
    end

    def ignore_path? path
      ignored_regex&.match?(path)
    end

    private

    attr_reader :dotfile

    def ignored_regex
      @ignored_regex ||= path_config_regex(dotfile.dig("routes", "paths", "ignore"))
    end

    def path_config_regex path_config
      return unless path_config

      config = path_config.map { |path| path.first == "^" ? path : "^#{path}$" }

      /#{config.join('|')}/
    end
  end
end
