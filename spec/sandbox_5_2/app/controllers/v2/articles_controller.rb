# frozen_string_literal: true

module V2
  class ArticlesController < ApplicationController
    # GET /v2/articles
    def index
      render json: {
        data: [
          {
            type: "articles",
            id: "1",
            attributes: {
              title: "article1", body: "anything1"
            }
          },
          {
            type: "articles",
            id: "2",
            attributes: {
              title: "article2", body: "anything2"
            }
          }
        ]
      }
    end

    # POST /v2/articles
    def create
      render json: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: params[:title].to_s, body: params[:body].to_s
          }
        }
      }, status: :created
    end

    # GET /v2/articles/:id
    def show
      render json: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: "article1", body: "anything"
          }
        }
      }
    end

    # PATCH /v2/articles/:id
    def update
      render json: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: params[:title].to_s, body: params[:body].to_s
          }
        }
      }
    end

    # DELETE /v2/articles/:id
    def destroy
      head :no_content
    end
  end
end
