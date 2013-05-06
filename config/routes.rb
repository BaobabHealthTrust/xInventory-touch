XInventory::Application.routes.draw do

  match 'home' => 'home#index'

  get "user/logout"
  post "user/login"

  ########## Donors #####################
  match 'donors' => 'donors#index'
  match 'create_new_donor' => 'donors#new'
  match 'donor_search' => 'donors#search'
  post "donors/create"
  #match 'donor_details' => 'donors#search'
  match 'donors_details/:id' => 'donors#show', :as => :donor_details
  # This route can be invoked with donor_details_url(:id => donor.id)
  ########## Donors end #####################

  ########## Projects #####################
  match 'projects' => 'projects#index'
  match 'create_new_project' => 'projects#new'
  match 'projects_search' => 'projects#search'
  post "projects/create"
  match 'project_details/:id' => 'projects#show', :as => :project_details
  # This route can be invoked with project_details_url(:id => project.id)
  ########## Projects end #####################

  ########## Suppliers #####################
  match 'suppliers' => 'suppliers#index'
  match 'create_new_supplier' => 'suppliers#new'
  match 'supplier_search' => 'suppliers#search'
  post "suppliers/create"
  match 'supplier_details/:id' => 'suppliers#show', :as => :supplier_details
  # This route can be invoked with supplier_details_url(:id => supplier.id)
  ########## Projects end #####################

  
  
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  root :to => 'user#login'
end
