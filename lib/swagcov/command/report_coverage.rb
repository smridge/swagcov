# frozen_string_literal: true

module Swagcov
  module Command
    class ReportCoverage
      def initialize data: ::Swagcov::Coverage.new.collect
        @data = data
      end

      def run
        ::Swagcov::Formatter::Console.new(data: @data).run
      end
    end
  end
end
