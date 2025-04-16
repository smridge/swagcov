# frozen_string_literal: true

module Swagcov
  class Coverage
    attr_reader :dotfile

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

    def collect
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

      @data
    end

    private

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
  end
end
