# frozen_string_literal: true

module Swagcov
  class Coverage
    attr_reader :data

    def initialize dotfile: ::Swagcov::Dotfile.new, routes: ::Rails.application.routes.routes
      @dotfile = dotfile
      @routes = routes
      @data = {
        covered: [],
        ignored: [],
        uncovered: [],
        total_count: 0,
        covered_count: 0,
        ignored_count: 0,
        uncovered_count: 0
      }
    end

    def report
      collect_coverage
      routes_output(@data[:covered], "green")
      routes_output(@data[:ignored], "yellow")
      routes_output(@data[:uncovered], "red")

      final_output

      @data[:uncovered_count]
    end

    private

    attr_reader :dotfile

    def collect_coverage
      openapi_files = ::Swagcov::OpenapiFiles.new(filepaths: dotfile.docs_config)
      rails_version = ::Rails::VERSION::STRING

      @routes.each do |route|
        path = route.path.spec.to_s.chomp("(.:format)")
        verb = rails_version > "5" ? route.verb : route.verb.inspect.gsub(%r{[$^/]}, "")

        next if third_party_route?(route, path, rails_version)

        if dotfile.ignore_path?(path, verb: verb)
          update_data(:ignored, verb, path, "ignored")
          next
        end

        next if dotfile.only_path_mismatch?(path)

        @data[:total_count] += 1

        if (response_keys = openapi_files.find_response_keys(path: path, route_verb: verb))
          update_data(:covered, verb, path, response_keys.join("  "))
        else
          update_data(:uncovered, verb, path, "none")
        end
      end
    end

    def third_party_route? route, path, rails_version
      # https://github.com/rails/rails/blob/48f3c3e201b57a4832314b2c957a3b303e89bfea/actionpack/lib/action_dispatch/routing/inspector.rb#L105-L107
      # Skips route paths like ["/rails/info/properties", "/rails/info", "/rails/mailers"]
      internal_rails_route?(route, rails_version) ||

        # Skips routes like "/sidekiq"
        route.verb.blank? ||

        # Exclude routes that are part of the rails gem that you would not write documentation for
        # https://github.com/rails/rails/tree/main/activestorage/app/controllers/active_storage
        # https://github.com/rails/rails/tree/main/actionmailbox/app/controllers/action_mailbox
        path.include?("/active_storage/") || path.include?("/action_mailbox/")
    end

    def internal_rails_route? route, rails_version
      if rails_version > "5"
        route.internal
      else
        ::ActionDispatch::Routing::RouteWrapper.new(route).internal?
      end
    end

    def update_data key, verb, path, status
      @data[:"#{key}_count"] += 1
      @data[key] << { verb: verb, path: path, status: status }
    end

    def routes_output routes, status_color
      routes.each do |route|
        $stdout.puts(
          format(
            "%<verb>10s %<path>-#{min_width(:path) + 1}s %<status>s",
            { verb: route[:verb], path: route[:path], status: route[:status].send(status_color) }
          )
        )
      end
    end

    def min_width key
      strings =
        @data[:covered].map { |hash| hash[key] } +
        @data[:ignored].map { |hash| hash[key] } +
        @data[:uncovered].map { |hash| hash[key] }

      strings.max_by(&:length).size
    end

    def final_output
      $stdout.puts
      $stdout.puts(
        format(
          "OpenAPI documentation coverage %<percentage>.2f%% (%<covered>d/%<total>d)",
          {
            percentage: 100.0 * @data[:covered_count] / @data[:total_count],
            covered: @data[:covered_count],
            total: @data[:total_count]
          }
        )
      )

      $stdout.puts(
        format(
          "%<total>s endpoints ignored",
          { total: @data[:ignored_count].to_s.yellow }
        )
      )

      $stdout.puts(
        format(
          "%<total>s endpoints checked",
          { total: @data[:total_count].to_s.blue }
        )
      )

      $stdout.puts(
        format(
          "%<covered>s endpoints covered",
          { covered: @data[:covered_count].to_s.green }
        )
      )

      $stdout.puts(
        format(
          "%<missing>s endpoints missing documentation",
          { missing: @data[:uncovered_count].to_s.red }
        )
      )
    end
  end
end
