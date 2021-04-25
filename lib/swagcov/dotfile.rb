# frozen_string_literal: true

module Swagcov
  class Dotfile
    def initialize
      @dotfile = YAML.load_file(Rails.root.join(".swagcov.yml"))
    end

    def ignore_path?(path)
      true
    end

    private

    attr_reader :dotfile
  end
end
