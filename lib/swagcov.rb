# frozen_string_literal: true

require "rails"
require "active_support/core_ext"

require "swagcov/core_ext/string"
require "swagcov/formatter/console"
require "swagcov/coverage"
require "swagcov/dotfile"
require "swagcov/errors"
require "swagcov/install"
require "swagcov/openapi_files"
require "swagcov/railtie"
require "swagcov/version"

module Swagcov
end
