# frozen_string_literal: true

module V1
  class ArticlesController < ApplicationController
    # GET /articles
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

    # POST /articles
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

    # GET /articles/:id
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

    # PATCH /articles/:id
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

    # DELETE /articles/:id
    def destroy
      head :no_content
    end
  end
end
