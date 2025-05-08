# frozen_string_literal: true

module Swagcov
  class Runner
    attr_reader :options

    def initialize args: ::ARGV
      @args = args
      @options = ::Swagcov::Options.new(args: @args).define
    end

    def run
      exit ::Swagcov::Command::GenerateDotfile.new.run if options[:init]
      exit ::Swagcov::Command::GenerateTodoFile.new.run if options[:todo]
      exit ::Swagcov::Command::ReportCoverage.new.run
    end
  end
end
