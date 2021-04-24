# frozen_string_literal: true

require "swagcov/version"

if defined?(Rails)
  require "swagcov/railtie"
  require "swagcov/coverage"
end

require "swagcov/core_ext/string"
require "swagcov/install"

module Swagcov
end
