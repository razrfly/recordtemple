Recordapp::Application.routes.draw do

  resources :user_accounts
  #resources :record_listings

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
  match 'stats' => 'statistics#index'

  devise_for :users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  resources :records do
    resources :record_listings
    resources :songs
    resources :photos do
      collection do
        put :sort
      end
    end
  end
  
  resources :prices
  resources :home
  resources :labels
  resources :searches do
    collection do
      get :autocomplete
    end
  end
  resources :recommendations

  root :to => "home#index"
  #match ':id' => 'artists#show', :as => :artist, :method => :get
  #match ':artist_id/:id' => 'records#show', :as => :artist_record, :method => :get

end
