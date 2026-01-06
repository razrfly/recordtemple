require 'admin_constraint'
require 'sidekiq/web'

Rails.application.routes.draw do
  # mount Avo::Engine, at: Avo.configuration.root_path, constraints: AdminConstraint.new  # Disabled - planned for removal
  mount Sidekiq::Web => "admin/sidekiq", constraints: AdminConstraint.new
  passwordless_for :users

  # Admin namespace
  namespace :admin do
    resources :variants, only: [:index] do
      collection do
        post :warmup
        post :clear_retries
        get :stats
      end
    end
  end

  # Dev-only auto-login bypass
  if Rails.env.development?
    get "dev_login", to: "dev_sessions#create"
  end

  # File serving via Active Storage (redirects to signed S3 URLs)
  get "files/photos/:id", to: "files#photo", as: :photo_file
  get "files/songs/:id", to: "files#song", as: :song_file

  # API endpoints for autocomplete
  namespace :api do
    resources :artists, only: [:index]
    resources :labels, only: [:index]
  end

  # Public record catalog
  resources :records, only: [:index, :show]

  # Discovery pages for artists and labels
  resources :artists, only: [:index, :show] do
    collection do
      get :random
    end
  end
  resources :labels, only: [:index, :show] do
    collection do
      get :random
    end
  end
  resources :genres, only: [:index, :show] do
    collection do
      get :random
    end
  end

  # Discovery page
  get 'discovery', to: 'discovery#index'
  get 'discovery/shuffle', to: 'discovery#shuffle'
  get 'discovery/quick_view/:id', to: 'discovery#quick_view', as: :discovery_quick_view

  root to: 'static#index'
end
