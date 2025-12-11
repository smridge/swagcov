# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  resources :articles
  resources :users

  namespace :v1 do
    resources :articles
  end

  namespace :v2 do
    resources :articles
  end

  mount Sidekiq::Web => "/sidekiq"
end
