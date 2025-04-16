# frozen_string_literal: true

require "rails"

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
  module_function

  def project_root
    ::Rails.root || ::Pathname.new(::FileUtils.pwd)
  end
end
