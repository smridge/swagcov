# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "/users" do
  path "/users" do
    get("list users") do
      tags "Users"
      produces "application/json"

      response(200, "successful") do
        schema(
          type: :object,
          additionalProperties: false,
          properties: {
            data: {
              type: :array,
              items: {
                "$ref" => "#/components/schemas/user"
              }
            }
          }
        )

        run_test!
      end
    end

    post("create user") do
      tags "Users"
      consumes "application/json"
      produces "application/json"

      parameter name: :user, in: :body, schema: {
        type: :object,
        additionalProperties: false,
        properties: {
          name: { type: :string },
          email: { type: :string }
        }
      }

      response(201, "created") do
        let(:user) { { name: "foo", email: "bar" } }

        schema(
          type: :object,
          additionalProperties: false,
          properties: {
            data: {
              "$ref" => "#/components/schemas/user"
            }
          }
        )

        run_test!
      end
    end
  end

  path "/users/{id}" do
    parameter name: "id", in: :path, type: :string, description: "id"

    get("show user") do
      tags "Users"
      produces "application/json"

      response(200, "successful") do
        let(:id) { "123" }
        schema(
          type: :object,
          additionalProperties: false,
          properties: {
            data: {
              "$ref" => "#/components/schemas/user"
            }
          }
        )

        run_test!
      end
    end

    patch("update user") do
      tags "Users"
      consumes "application/json"
      produces "application/json"

      response(200, "successful") do
        let(:id) { "123" }
        schema(
          type: :object,
          additionalProperties: false,
          properties: {
            data: {
              "$ref" => "#/components/schemas/user"
            }
          }
        )

        run_test!
      end
    end

    put("update user") do
      tags "Users"
      consumes "application/json"
      produces "application/json"

      response(200, "successful") do
        let(:id) { "123" }
        schema(
          type: :object,
          additionalProperties: false,
          properties: {
            data: {
              "$ref" => "#/components/schemas/user"
            }
          }
        )

        run_test!
      end
    end

    delete("delete user") do
      tags "Users"

      response(204, "deleted") do
        let(:id) { "123" }

        run_test!
      end
    end
  end
end
