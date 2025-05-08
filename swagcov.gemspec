# frozen_string_literal: true

require_relative "lib/swagcov/version"

Gem::Specification.new do |spec|
  spec.name     = "swagcov"
  spec.version  = Swagcov::Version::STRING
  spec.authors  = ["Sarah Ridge"]
  spec.email    = ["sarahmarie@hey.com"]
  spec.summary  = "OpenAPI documentation coverage report for Rails Route endpoints"
  spec.homepage = "https://github.com/smridge/swagcov"
  spec.license  = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*", "CHANGELOG.md", "LICENSE", "README.md"]
  spec.bindir = "exe"
  spec.executables = ["swagcov"]

  spec.required_ruby_version = ">= 2.5.0"
  spec.add_dependency "railties", ">= 4.2"
end
