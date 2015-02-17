Recordapp::Application.routes.draw do
  root to: "home#index"

  devise_for :users
  devise_scope :user do
    get "login", :to => "devise/sessions#new"
  end

  resources :record_formats, :genres, :labels, :artists
  resources :prices do
    resources :records
  end

  resources :records do
    resources :songs, :photos
  end

  namespace :admin do
    root to: 'home#index'
    put 'artists' => 'artists#index'
    put 'prices'  => 'prices#index'
    put 'labels'  => 'labels#index'
    put 'records' => 'records#index'
    put 'songs'   => 'songs#index'
    # delete 'unlink_record' => 'prices#unlink(:id)'
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
