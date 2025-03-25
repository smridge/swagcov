# frozen_string_literal: true

module Swagcov
  class Coverage
    attr_reader :total, :covered, :ignored, :routes_not_covered, :routes_covered, :routes_ignored

    def initialize dotfile: Swagcov::Dotfile.new, routes: ::Rails.application.routes.routes
      @total = 0
      @covered = 0
      @ignored = 0
      @routes_not_covered = []
      @routes_covered = []
      @routes_ignored = []
      @dotfile = dotfile
      @routes = routes
    end

    def report
      collect_coverage
      routes_output(@routes_covered, "green")
      routes_output(@routes_ignored, "yellow")
      routes_output(@routes_not_covered, "red")

      final_output

      @total - @covered
    end

    private

    attr_reader :dotfile

    def collect_coverage
      openapi_files = ::Swagcov::OpenapiFiles.new(filepaths: dotfile.doc_paths)

      @routes.each do |route|
        path = route.path.spec.to_s.chomp("(.:format)")

        next if third_party_route?(route, path)

        if dotfile.ignore_path?(path, verb: route.verb)
          @ignored += 1
          @routes_ignored << { verb: route.verb, path: path, status: "ignored" }
          next
        end

        next if dotfile.only_path_mismatch?(path)

        @total += 1

        if (response_keys = openapi_files.find_response_keys(path: path, route_verb: route.verb))
          @covered += 1
          @routes_covered << { verb: route.verb, path: path, status: response_keys.join("  ") }
        else
          @routes_not_covered << { verb: route.verb, path: path, status: "none" }
        end
      end
    end

    def third_party_route? route, path
      # https://github.com/rails/rails/blob/48f3c3e201b57a4832314b2c957a3b303e89bfea/actionpack/lib/action_dispatch/routing/inspector.rb#L105-L107
      # Skips route paths like ["/rails/info/properties", "/rails/info", "/rails/mailers"]
      route.internal ||

        # Skips routes like "/sidekiq"
        route.verb.blank? ||

        # Exclude routes that are part of the rails gem that you would not write documentation for
        # https://github.com/rails/rails/tree/main/activestorage/app/controllers/active_storage
        # https://github.com/rails/rails/tree/main/actionmailbox/app/controllers/action_mailbox
        path.include?("/active_storage/") || path.include?("/action_mailbox/")
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
        @routes_covered.map { |hash| hash[key] } +
        @routes_ignored.map { |hash| hash[key] } +
        @routes_not_covered.map { |hash| hash[key] }

      strings.max_by(&:length).size
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
