# frozen_string_literal: true

require "swagcov/version"

if defined?(Rails)
  require "swagcov/railtie"
  require "swagcov/dotfile"
  require "swagcov/coverage"
  require "swagcov/openapi_files"
end

require "swagcov/core_ext/string"

module Swagcov
end
