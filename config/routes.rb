Recordapp::Application.routes.draw do

  root to: "home#index"
  # ransack and selectize

  devise_for :users, controllers: { registrations: "users/registrations" }
  devise_scope :user do
    get "login", to: "devise/sessions#new"
  end

  resources :labels, :artists, :records, only: [:index, :show]
  resources :genres, :record_types, only: [:show]
  get 'search', to: 'searches#new'

  namespace :admin do
    root to: 'home#index'
    # ransack and selectize
    put 'artists' => 'artists#index'
    put 'prices'  => 'prices#index'
    put 'labels'  => 'labels#index'
    put 'records' => 'records#index'
    put 'songs'   => 'songs#index'

    # get ':user_id/pages', to: 'pages#index', as: 'user_pages'
    resources :pages do
      post 'sort', to: 'pages#sort', on: :collection
    end


    resources :genres, :record_formats, :record_types, except: :show
    resources :pages, only: [:index]
    resources :users
    resources :invitations, only: [:new, :create]
    resources :artists, :prices, :labels
    resources :records do
      resources :songs, :photos
      delete 'unlink_price', on: :member
    end
    resources :prices do
      resources :records
    end

    # sticky navigation
    post 'sticky' => 'admin#sticky'

  end

  constraints(user_id: /rui|greggie|holden|szymon|simon|twitwilly|steve/) do
    get ':user_id', to: 'users#show', as: 'user'
    get ':user_id/records', to: 'records#index', as: 'user_records'
    get ':user_id/pages', to: 'pages#index', as: 'user_pages'
    get ':user_id/:id', to: 'pages#show', as: 'user_page'
  end
  get 'users', to: 'users#index'

end
