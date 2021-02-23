# frozen_string_literal: true

require "swagcov/version"

if defined?(Rails)
  require "swagcov/railtie"
  require "swagcov/coverage"
end

module Swagcov
end
