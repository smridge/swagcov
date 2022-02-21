# frozen_string_literal: true

class UsersController < ApplicationController
  # GET /users
  def index
    render json: {
      data: [
        {
          type: "users",
          id: "1",
          attributes: {
            name: "anyone", email: "anyone@anything.com"
          }
        },
        {
          type: "users",
          id: "2",
          attributes: {
            name: "someone", email: "someone@anything.com"
          }
        }
      ]
    }
  end

  # POST /users
  def create
    render json: {
      data: {
        type: "users",
        id: "1",
        attributes: {
          name: params[:name].to_s, email: params[:email].to_s
        }
      }
    }, status: :created
  end

  # GET /users/:id
  def show
    render json: {
      data: {
        type: "users",
        id: "1",
        attributes: {
          name: "anyone", email: "anyone@anything.com"
        }
      }
    }
  end

  # PATCH /users/:id
  def update
    render json: {
      data: {
        type: "users",
        id: "1",
        attributes: {
          name: params[:name].to_s, email: params[:email].to_s
        }
      }
    }
  end

  # DELETE /users/:id
  def destroy
    head :no_content
  end
end
