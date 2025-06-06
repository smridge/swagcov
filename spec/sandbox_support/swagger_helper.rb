# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder

  openapi_root = Rails.root.join("swagger").to_s

  config.respond_to?(:openapi_root) ? config.openapi_root = openapi_root : config.swagger_root = openapi_root

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  openapi_specs = {
    "openapi.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "API V1",
        version: "v1"
      },
      paths: {},
      servers: [
        {
          url: "https://{defaultHost}",
          variables: {
            defaultHost: {
              default: "www.example.com"
            }
          }
        }
      ],
      components: {
        schemas: {
          article: {
            additionalProperties: false,
            type: :object,
            properties: {
              type: { type: :string },
              id: { type: :string },
              attributes: {
                additionalProperties: false,
                type: :object,
                properties: {
                  title: { type: :string },
                  body: { type: :string }
                }
              }
            }
          },
          user: {
            additionalProperties: false,
            type: :object,
            properties: {
              type: { type: :string },
              id: { type: :string },
              attributes: {
                additionalProperties: false,
                type: :object,
                properties: {
                  name: { type: :string },
                  email: { type: :string }
                }
              }
            }
          }
        }
      }
    }
  }

  config.respond_to?(:openapi_specs) ? config.openapi_specs = openapi_specs : config.swagger_docs = openapi_specs

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  openapi_format = :yaml

  config.respond_to?(:openapi_format) ? config.openapi_format = openapi_format : config.swagger_format = openapi_format
end
