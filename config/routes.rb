Recordapp::Application.routes.draw do
  # mount Blazer::Engine, at: 'blazer'

  root to: "home#index"

  devise_for :users,
  skip: [:registrations],
  path: '',
  path_names: {
    sign_in: 'login',
    sign_out: 'logout'
    },
  controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  as :user do
    get "login", to: "users/sessions#new"
    delete "logout", to: "users/sessions#destroy"

    get "settings", to: "users/registrations#edit"
    put "users", to: "users/registrations#update",
      as: 'user_registration'
  end

  scope path: ":user_id", as: "user" do
    resources :records, only: [:index, :show]
  end

  get 'search', to: 'searches#new'
  resources :labels, :artists, :records, only: [:index, :show]
  resources :genres, :record_types, only: [:show]
  resources :prices, only: [:index, :show] do
    resources :records, only: [:new, :create]
  end

  #Dont know what is it for
  # constraints(user_id: /rui|greggie|holden|szymon|simon|twitwilly|steve/) do
  #   get ':user_id', to: 'users#show', as: 'user'
  #   get ':user_id/records', to: 'records#index', as: 'user_records'
  #   get ':user_id/pages', to: 'pages#index', as: 'user_pages'
  #   get ':user_id/:id', to: 'pages#show', as: 'user_page'
  # end
  # get 'users', to: 'users#index'
end
