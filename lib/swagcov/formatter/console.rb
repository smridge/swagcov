# frozen_string_literal: true

module Swagcov
  module Formatter
    class Console
      attr_reader :data

      def initialize data: ::Swagcov::Coverage.new.collect
        @data = data
      end

      def run
        routes_output(data[:covered], "green")
        routes_output(data[:ignored], "yellow")
        routes_output(data[:uncovered], "red")
        final_output

        data[:uncovered_count]
      end

      private

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
          data[:covered].map { |hash| hash[key] } +
          data[:ignored].map { |hash| hash[key] } +
          data[:uncovered].map { |hash| hash[key] }

        strings.max_by(&:length).size
      end

      def final_output
        $stdout.puts
        $stdout.puts(
          format(
            "OpenAPI documentation coverage %<percentage>.2f%% (%<covered>d/%<total>d)",
            {
              percentage: 100.0 * data[:covered_count] / data[:total_count],
              covered: data[:covered_count],
              total: data[:total_count]
            }
          )
        )

        count_output
      end

      def count_output
        {
          ignored: "yellow",
          total: "blue",
          covered: "green",
          uncovered: "red"
        }.each do |key, color|
          count = data[:"#{key}_count"]

          $stdout.puts(
            format(
              "%<status>s #{key} #{count == 1 ? 'endpoint' : 'endpoints'}",
              { status: count.to_s.send(color) }
            )
          )
        end
      end
    end
  end
end
