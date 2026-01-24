# frozen_string_literal: true

module Swagcov
  module Formatter
    class Console
      attr_reader :data, :min_path_width

      def initialize data: ::Swagcov::Coverage.new.collect
        @data = data
        @min_path_width = calc_min_path_width
      end

      def run
        routes_output(data[:covered], "green")
        routes_output(data[:ignored], "yellow")
        routes_output(data[:uncovered], "red")
        final_output

        data[:uncovered_count].zero? ? ::Swagcov::STATUS_SUCCESS : ::Swagcov::STATUS_OFFENSES
      end

      private

      def calc_min_path_width
        paths = data.values_at(:covered, :ignored, :uncovered).flat_map { |routes| routes.map { |route| route[:path] } }
        paths.max_by(&:length)&.size.to_i + 1
      end

      def routes_output routes, status_color
        routes.each do |route|
          $stdout.puts(
            format(
              "%<verb>10s %<path>-#{min_path_width}s %<status>s",
              { verb: route[:verb], path: route[:path], status: route[:status].send(status_color) }
            )
          )
        end
      end

      def final_output
        total_count = data[:total_count]
        covered_count = data[:covered_count]

        $stdout.puts
        $stdout.puts(
          format(
            "OpenAPI documentation coverage %<percentage>.2f%% (%<covered>d/%<total>d)",
            {
              percentage: total_count.zero? ? 0.0 : 100.0 * covered_count / total_count,
              covered: covered_count,
              total: total_count
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
