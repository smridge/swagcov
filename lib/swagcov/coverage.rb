# frozen_string_literal: true

module Swagcov
  class Coverage
    def initialize
      @total = 0
      @covered = 0
      @ignored = 0
      @routes_not_covered = []
      @routes_covered = []
      @routes_ignored = []
    end

    def report
      Rails.application.routes.routes.each do |route|
        # https://github.com/rails/rails/blob/48f3c3e201b57a4832314b2c957a3b303e89bfea/actionpack/lib/action_dispatch/routing/inspector.rb#L105-L107
        # Skips route paths like ["/rails/info/properties", "/rails/info", "/rails/mailers"]
        next if route.internal

        # Skips routes like "/sidekiq"
        next unless route.verb.present?

        path = route.path.spec.to_s.sub(/\(\.:format\)$/, "")

        if ignore_path?(path)
          @ignored += 1
          @routes_ignored << { verb: route.verb, path: path, status: "ignored" }
          next
        end

        next if only_path_mismatch?(path)

        @total += 1
        regex = Regexp.new("#{path.gsub(%r{:[^/]+}, '\\{[^/]+\\}')}(\\.[^/]+)?$")
        matching_keys = docs_paths.keys.select { |k| regex.match?(k) }

        if (doc = docs_paths.dig(matching_keys.first, route.verb.downcase))
          @covered += 1
          @routes_covered << { verb: route.verb, path: path, status: doc["responses"].keys.map(&:to_s).sort.join("  ") }
        else
          @routes_not_covered << { verb: route.verb, path: path, status: "none" }
        end
      end

      routes_output(@routes_covered, "green")
      routes_output(@routes_ignored, "yellow")
      routes_output(@routes_not_covered, "red")

      final_output

      exit @total - @covered
    end

    def dotfile
      @dotfile ||= YAML.load_file(Rails.root.join(".swagcov.yml"))
    end

    def docs_paths
      @docs_paths ||= Dir.glob(dotfile["docs"]["paths"]).reduce({}) do |acc, docspath|
        acc.merge(YAML.load_file(docspath)["paths"])
      end
    end

    private

    def ignore_path? path
      ignored_regex&.match?(path)
    end

    def ignored_regex
      @ignored_regex ||= path_config_regex(dotfile.dig("routes", "paths", "ignore"))
    end

    def only_path_mismatch? path
      only_regex && !only_regex.match?(path)
    end

    def only_regex
      @only_regex ||= path_config_regex(dotfile.dig("routes", "paths", "only"))
    end

    def path_config_regex path_config
      return unless path_config

      config = path_config.map { |path| path.first == "^" ? path : "#{path}$" }

      /#{config.join('|')}/
    end

    def routes_output routes, status_color
      routes.each do |route|
        $stdout.puts(
          format(
            "%<verb>10s    %<path>-90s    %<status>s",
            { verb: route[:verb], path: route[:path], status: route[:status].send(status_color) }
          )
        )
      end
    end

    def final_output
      $stdout.puts
      $stdout.puts(
        format(
          "OpenAPI documentation coverage %<percentage>.2f%% (%<covered>d/%<total>d)",
          { percentage: 100.0 * @covered / @total, covered: @covered, total: @total }
        )
      )

      $stdout.puts(
        format(
          "%<total>s endpoints ignored",
          { total: @ignored.to_s.yellow }
        )
      )

      $stdout.puts(
        format(
          "%<total>s endpoints checked",
          { total: @total.to_s.blue }
        )
      )

      $stdout.puts(
        format(
          "%<covered>s endpoints covered",
          { covered: @covered.to_s.green }
        )
      )

      $stdout.puts(
        format(
          "%<missing>s endpoints missing documentation",
          { missing: (@total - @covered).to_s.red }
        )
      )
    end
  end
end
