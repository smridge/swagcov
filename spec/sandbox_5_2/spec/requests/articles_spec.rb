# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "/articles" do
  path "/articles" do
    get("list articles") do
      tags "Articles"
      produces "application/json"

      response(200, "successful") do
        schema(
          type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                "$ref" => "#/components/schemas/article"
              }
            }
          }
        )

        run_test!
      end
    end

    post("create article") do
      tags "Articles"
      consumes "application/json"
      produces "application/json"

      parameter name: :article, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          body: { type: :string }
        }
      }

      response(201, "created") do
        let(:article) { { title: "foo", body: "bar" } }

        schema(
          type: :object,
          properties: {
            data: {
              "$ref" => "#/components/schemas/article"
            }
          }
        )

        run_test!
      end
    end
  end

  path "/articles/{id}" do
    parameter name: "id", in: :path, type: :string, description: "id"

    get("show article") do
      tags "Articles"
      produces "application/json"

      response(200, "successful") do
        let(:id) { "123" }
        schema(
          type: :object,
          properties: {
            data: {
              "$ref" => "#/components/schemas/article"
            }
          }
        )

        run_test!
      end
    end

    patch("update article") do
      tags "Articles"
      consumes "application/json"
      produces "application/json"

      response(200, "successful") do
        let(:id) { "123" }
        schema(
          type: :object,
          properties: {
            data: {
              "$ref" => "#/components/schemas/article"
            }
          }
        )

        run_test!
      end
    end

    put("update article") do
      tags "Articles"
      consumes "application/json"
      produces "application/json"

      response(200, "successful") do
        let(:id) { "123" }
        schema(
          type: :object,
          properties: {
            data: {
              "$ref" => "#/components/schemas/article"
            }
          }
        )

        run_test!
      end
    end

    delete("delete article") do
      tags "Articles"

      response(204, "deleted") do
        let(:id) { "123" }

        run_test!
      end
    end
  end
end
