Recordapp::Application.routes.draw do

  devise_for :users
  devise_scope :user do
    get "login", :to => "devise/sessions#new"
  end

  resources :record_formats

  resources :artists do
    resources :records
  end
  #match ':id' => 'artists#show', :as => :artist, :method => :get
  #match ':artist_id/:id' => 'records#show', :as => :root_record
  #match ':id' => 'artists#show'
  #match ':artist_id/:id' => 'records#show'
  
  resources :genres

  #get "statistics/index"
  get 'stats' => 'statistics#index'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  resources :records do
    resources :songs
    resources :photos do
      collection do
        put :sort
      end
    end
  end
  
  resources :prices do
    get :autocomplete_artist_name, :on => :collection
    get :autocomplete_label_name, :on => :collection
  end
  resources :home
  resources :labels

  root :to => "home#index"

  namespace :admin do
    root :to => 'home#index'
    
    resources :artists do
      resources :prices
    end
    
    resources :labels
    resources :genres
    resources :record_formats
    resources :record_types
    resources :users
  end
end
