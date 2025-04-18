# frozen_string_literal: true

module Swagcov
  module Command
    class ReportCoverage
      def initialize data: nil
        @data = data
      end

      def run
        data = @data || ::Swagcov::Coverage.new.collect

        ::Swagcov::Formatter::Console.new(data: data).run
      rescue ::Swagcov::Errors::BadConfiguration => e
        warn "#{e.class}: #{e.message}"
        ::Swagcov::STATUS_ERROR
      end
    end
  end
end
