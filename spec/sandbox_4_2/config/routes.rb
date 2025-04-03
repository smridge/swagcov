# frozen_string_literal: true

Rails.application.routes.draw do
  resources :articles, except: %i[new edit]
  resources :users, except: %i[new edit]

  namespace :v1 do
    resources :articles, except: %i[new edit]
  end

  namespace :v2 do
    resources :articles, except: %i[new edit]
  end
end
