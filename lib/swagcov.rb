# frozen_string_literal: true

require "rails"

require "swagcov/command/generate_dotfile"
require "swagcov/command/generate_todo_file"
require "swagcov/command/report_coverage"
require "swagcov/command/report_version"
require "swagcov/core_ext/string"
require "swagcov/formatter/console"
require "swagcov/coverage"
require "swagcov/dotfile"
require "swagcov/errors"
require "swagcov/openapi_files"
require "swagcov/options"
require "swagcov/railtie"
require "swagcov/runner"
require "swagcov/version"

module Swagcov
  module_function

  STATUS_SUCCESS     = 0
  STATUS_OFFENSES    = 1
  STATUS_ERROR       = 2

  DOTFILE = ENV["SWAGCOV_DOTFILE"] ||= ".swagcov.yml"
  TODOFILE = ENV["SWAGCOV_TODOFILE"] ||= ".swagcov_todo.yml"

  def project_root
    ::Rails.root || ::Pathname.new(::FileUtils.pwd)
  end

  def project_routes
    ::Rails.application&.routes&.routes || []
  end
end
