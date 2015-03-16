Recordapp::Application.routes.draw do
  root to: "home#index"
  # ransack and selectize

  devise_for :users, controllers: { registrations: "users/registrations" }
  devise_scope :user do
    get "login", :to => "devise/sessions#new"
  end

  resources :labels, :artists, :records, only: [:index, :show]
  get 'search', to: 'searches#new'
  #post 'search', to: 'search#index'

  namespace :admin do
    root to: 'home#index'
    # ransack and selectize
    put 'artists' => 'artists#index'
    put 'prices'  => 'prices#index'
    put 'labels'  => 'labels#index'
    put 'records' => 'records#index'
    put 'songs'   => 'songs#index'

    resources :genres, :record_formats, :record_types, :users, except: :show
    resources :invitations, only: [:new, :create]
    resources :artists, :prices, :labels
    resources :records do
      resources :songs, :photos
      delete 'unlink_price', :on => :member
    end
    resources :prices do
      resources :records
    end

  end

end
