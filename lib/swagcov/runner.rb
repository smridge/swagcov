# frozen_string_literal: true

module Swagcov
  class Runner
    attr_reader :options

    def initialize args: ::ARGV
      @args = args
      @options = ::Swagcov::Options.new(args: @args).define
    end

    def run
      exit runner
    end

    private

    def runner
      return ::Swagcov::Command::GenerateDotfile.new.run if options[:init]
      return ::Swagcov::Command::GenerateTodoFile.new.run if options[:todo]
      return ::Swagcov::Command::ReportVersion.new.run if options[:version]

      ::Swagcov::Command::ReportCoverage.new.run
    end
  end
end
