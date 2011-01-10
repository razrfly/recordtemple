Recordapp::Application.routes.draw do

  resources :user_accounts
  #resources :record_listings

  resources :record_formats

  resources :artists do
    resources :records
  end
  #match ':id' => 'artists#show', :as => :artist, :method => :get
  #match ':artist_id/:id' => 'records#show', :as => :root_record
  
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
  end
  
  resources :prices
  resources :photos
  resources :songs
  resources :home
  resources :labels
  resources :searches do
    collection do
      get :autocomplete
    end
  end
  resources :recommendations

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
