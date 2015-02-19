Recordapp::Application.routes.draw do
  root to: "home#index"
  # ransack and selectize
  put 'artists' => 'artists#index'
  put 'prices'  => 'prices#index'
  put 'labels'  => 'labels#index'
  put 'records' => 'records#index'
  put 'songs'   => 'songs#index'

  devise_for :users
  devise_scope :user do
    get "login", :to => "devise/sessions#new"
  end

  resources :labels, :prices, :artists, :records, only: [:index, :show]

  namespace :admin do
    root to: 'home#index'
    # ransack and selectize
    put 'artists' => 'artists#index'
    put 'prices'  => 'prices#index'
    put 'labels'  => 'labels#index'
    put 'records' => 'records#index'
    put 'songs'   => 'songs#index'

    resources :genres, :record_formats, :record_types, :users, except: :show
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
