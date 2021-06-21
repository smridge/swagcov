# frozen_string_literal: true

Rails.application.routes.draw do
  resources :articles

  namespace :v1 do
    resources :articles
  end

  namespace :v2 do
    resources :articles
  end
end
