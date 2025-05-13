# frozen_string_literal: true

module Swagcov
  class Dotfile
    def initialize basename: ::Swagcov::DOTFILE, todo_basename: ::Swagcov::TODOFILE, skip_todo: false
      @dotfile = load_yaml(basename, required: true)

      raise ::Swagcov::Errors::BadConfiguration, "Invalid config file (#{::Swagcov::DOTFILE})" unless valid?

      @todo_file = load_yaml(todo_basename) unless skip_todo
      @ignored_regex = path_config_regex(ignored_config)
      @only_regex = path_config_regex(only_config)
    end

    def ignore_path? path, verb:
      return false unless @ignored_config

      ignore_all_path_actions = @ignored_regex.match?(path)

      ignored_verbs =
        @ignored_config.select { |config| config[path]&.is_a?(::Array) }.map(&:values).flatten.map(&:downcase)

      return ignore_all_path_actions if ignored_verbs.empty?

      ignored_verbs.any?(verb.downcase)
    end

    def only_path_mismatch? path
      @only_config && !@only_regex.match?(path)
    end

    def docs_config
      @docs_config ||= dotfile.dig("docs", "paths")
    end

    def ignored_config
      dotfile_routes = dotfile.dig("routes", "paths", "ignore").to_a
      todo_routes = todo_file ? todo_file.dig("routes", "paths", "ignore").to_a : []
      routes = dotfile_routes + todo_routes

      @ignored_config ||= routes.empty? ? nil : routes
    end

    def only_config
      @only_config ||= dotfile.dig("routes", "paths", "only")
    end

    private

    attr_reader :dotfile, :todo_file

    def load_yaml basename, required: false
      pathname = ::Swagcov.project_root.join(basename)

      raise ::Swagcov::Errors::BadConfiguration, "Missing config file (#{basename})" if !pathname.exist? && required

      return unless pathname.exist?

      ::YAML.load_file(pathname)
    rescue ::Psych::SyntaxError
      raise ::Swagcov::Errors::BadConfiguration, "Malformed config file (#{basename})"
    end

    def path_config_regex path_config
      return unless path_config

      config =
        path_config.map do |path|
          if path.is_a?(::Hash)
            "^#{path.keys.first}$"
          else
            path.chr == "^" ? path : "^#{path}$"
          end
        end

      /#{config.join('|')}/
    end

    def valid?
      dotfile && docs_config
    end
  end
end
