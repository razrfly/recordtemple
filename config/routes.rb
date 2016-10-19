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

  resources :records do
    resources :photos, only: [:create, :destroy, :edit, :update]
    resources :songs, only: [:create, :destroy, :edit, :update]
  end

  resources :labels, :artists, only: [:index, :show]
  resources :genres, :record_types, only: [:show]

  resources :prices, only: [:index, :show] do
    resources :records, only: [:new, :create]
  end

  get 'search', to: 'searches#new'
end
