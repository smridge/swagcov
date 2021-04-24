# frozen_string_literal: true

module Swagcov
  class Install
    def generate_dotfile
      dotfile = Rails.root.join(".swagcov.yml").to_s

      return if File.exist?(dotfile)

      File.write(
        Rails.root.join(dotfile).to_s,
        {
          "docs" => {
            "paths" => ["TODO: *required* list your openapi swagger file(s) here"]
          },
          "routes" => {
            "paths" => {
              "only" => ["TODO: *optional* For example if you only want to track `^v1` endpoints"],
              "ignore" => ["TODO: *optional* For endpoints you may not want to track", "v1/foo/already_merged"]
            }
          }
        }.to_yaml
      )
    end
  end
end
