# frozen_string_literal: true

module Swagcov
  module Command
    class ReportVersion
      def run
        $stdout.puts ::Swagcov::Version::STRING

        ::Swagcov::STATUS_SUCCESS
      end
    end
  end
end
