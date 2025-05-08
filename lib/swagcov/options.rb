# frozen_string_literal: true

require "optparse"

module Swagcov
  class Options
    def initialize args: ::ARGV
      @args = args
    end

    def define
      options = {}

      ::OptionParser.new do |opts|
        opts.banner = <<~MESSAGE
          Usage:
          * as executable: swagcov [options]
          * as rake task: rake swagcov -- [options]
        MESSAGE

        opts.on("-i", "--init", "Generate required .swagcov.yml config file") do |opt|
          options[:init] = opt
        end

        opts.on("-t", "--todo", "Generate optional .swagcov_todo.yml config file") do |opt|
          options[:todo] = opt
        end
      end.parse!(@args)

      options
    rescue ::OptionParser::InvalidOption => e
      warn e.message
      warn "For usage information, use --help"
      exit ::Swagcov::STATUS_ERROR
    end
  end
end
