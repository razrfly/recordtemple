require 'admin_constraint'
require 'sidekiq/web'

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  # mount Avo::Engine, at: Avo.configuration.root_path, constraints: AdminConstraint.new  # Disabled - planned for removal
  mount Sidekiq::Web => "admin/sidekiq", constraints: AdminConstraint.new

  # Admin area
  namespace :admin, constraints: AdminConstraint.new do
    root to: "dashboard#index"
    # No :destroy — record deletion is consolidated onto the public
    # confirm_delete flow so there is one code path and one copy deck (#384).
    resources :records, only: [:index, :show, :update] do
      member do
        patch :add_images
        patch :add_songs
        delete :destroy_attachment
        get :preview
      end
    end
    resources :discogs_review, only: [:index, :show] do
      member do
        post :search
        post :link
        post :skip
      end
    end
    resources :price_review, only: [:show] do
      member do
        post :search
        post :link
        post :clear
      end
    end
    resources :prices, only: [:edit, :update]
  end
  passwordless_for :users

  # Dev-only auto-login bypass
  if Rails.env.development?
    get "dev_login", to: "dev_sessions#create"
  end

  # File serving via Active Storage (redirects to signed S3 URLs)
  get "files/photos/:id", to: "files#photo", as: :photo_file
  get "files/songs/:id", to: "files#song", as: :song_file

  # Song streaming URL endpoint (returns signed URL via JSON)
  # Uses signed_id to prevent enumeration attacks
  get "songs/stream_url/:signed_id", to: "songs#stream_url", as: :song_stream_url

  # API endpoints for autocomplete
  namespace :api do
    resources :artists, only: [:index, :create]
    resources :labels, only: [:index, :create]
    resources :prices, only: [:index, :create]
  end

  # Public record catalog with authenticated CRUD
  resources :records do
    member { get :confirm_delete }
  end

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
