XInventory::Application.routes.draw do


  get "locations" => "locations#index"

  match "add_location" => "locations#add_location"

  match "print_location" => "locations#print_location"
  match 'print_barcode/:id' => 'locations#print_barcode'

  match 'validate_name/:id' => 'locations#validate_name', :as => :validate_name

  match 'validate_category/:id' => 'assets#validate_category', :as => :validate_category

  match 'validate_state/:id' => 'assets#validate_state', :as => :validate_state

  ########## home starts #####################
  match 'home' => 'home#index'
  ########## home ends #####################

  ########## fleet_management starts #####################
  match "/fleet_management" => "fleet_management#index"
  ########## fleet_management ends #####################


  ########## Users start #####################
  match 'login' => 'user#login'
  get "user/logout"
  get "location" => 'user#location'
  post "find_location" => 'user#find_location'
  post "user/login"
  match 'edit_user/:id' => 'user#edit', :as => :edit_user
  post "user/update"
  match 'settings/:id' => 'user#index', :as => :settings
  match 'new_user' => 'user#new'
  post 'user/create'
  match 'remove_user/:id' => 'user#delete', :as => :remove_user
  match 'assign_role/:id' => 'user#roles', :as => :assign_role
  post 'user/assign_role'
  match '/username_availability' => 'user#username_availability'
  match 'details/:id' => 'user#show', :as => :details
  match 'assign_role' => 'user#assign_role'
  ########## Users end #####################

  ########## Reports start #####################
  match 'reports' => 'reports#index'

  match 'stock_balances' => 'reports#stock_balances'
  match 'dispatched_assets' => 'reports#list_of_dispatched_assets'
  match 'items_bought_in' => 'reports#list_of_items_bought_in'
  match 'transfers' => 'reports#transfers'
  match '/search_for_dispatched_assets' => 'reports#search_for_dispatched_assets'
  match '/search_for_assets_bought_in' => 'reports#search_for_assets_bought_in'
  match '/search_for_stock_balances' => 'reports#search_for_stock_balances'
  match '/search_for_transfers' => 'reports#search_for_transfers'
  match '/advanced_stock_balances'=> 'reports#advanced_stock_balances'
  match '/advanced_stock_balances_search' => 'reports#advanced_stock_balances_search'
  ########## Reports end #####################

  ########## dispatch_receive start #####################
  match 'dispatch_receive' => 'dispatch_receive#index'
  match 'dispatch_approval' => 'dispatch_receive#approve'
  match 'confirm' => 'dispatch_receive#confirm'
  match 'search/:id' => 'dispatch_receive#search', :as => :assets_to
  match 'dispatch/:id' => 'dispatch_receive#dispatch_asset', :as => :dispatch
  match 'receive/:id' => 'dispatch_receive#receive_asset', :as => :receive
  match 'item/:id' => 'dispatch_receive#item', :as => :item
  match 'selected_assets' => 'dispatch_receive#asset_transfers', :as => :selected_assets
  match 'transfer_assets_search' => 'dispatch_receive#transfer_assets_search'
  match 'process_transfer' => 'dispatch_receive#process_transfer'
  match 'transfer_results/:id' => 'dispatch_receive#transfer_results', :as => :transfer_results
  match 'dispatch_live_search' => 'dispatch_receive#live_search'
  match 'borrowed_assets' => 'dispatch_receive#borrowed_assets'
  match 'available_asset_list/:id' => 'dispatch_receive#borrowed_assets_reimburse', :as => :available_asset_list
  match 'reimburse/:id/:reimbursed_id' => 'dispatch_receive#reimburse', :as => :reimburse
  post "dispatch_receive/reimburse_create"
  match 'transfer/:id' => 'dispatch_receive#transfer', :as => :transfer
  match 'batch_dispatch' => 'dispatch_receive#batch_dispatch'
  match 'batch_return' => 'dispatch_receive#batch_return'
  #post  'dispatch_receive/create'
  match 'dispatch_user_search' => 'dispatch_receive#live_user'
  match 'item' => "dispatch_receive#item"
  match 'init_dispatch' => "dispatch_receive#create"
  match 'init_return' => "dispatch_receive#init_return"
  match '/find_asset_to_dispatch_by_barcode' => 'dispatch_receive#find_asset_to_dispatch_by_barcode'
  match '/find_asset_to_return_by_barcode' => 'dispatch_receive#find_asset_to_return_by_barcode'
  match '/create_batch_dispatch' => 'dispatch_receive#create_batch_dispatch'
  match '/create_batch_return' => 'dispatch_receive#create_batch_return'
  match '/batch_transfer' => 'dispatch_receive#batch_transfer'
  get  'dispatch_receive/init_transfer'
  match '/create_batch_transfer' => 'dispatch_receive#create_batch_transfer'
  match '/batch_reimburse_create' => 'dispatch_receive#batch_reimburse_create'
  ########## dispatch_receive end #####################

  ########## Donors #####################
  match 'donors' => 'donors#index'
  match 'create_new_donor' => 'donors#new'
  match 'donor_search' => 'donors#search'
  post "donors/create"
  match 'donors_details/:id' => 'donors#show', :as => :donor_details
  match 'edit_donor_details/:id' => 'donors#edit_donor_details', :as => :edit_donor_details
  post "donors/edit_donor_details"
  match 'delete_donor/:id' => 'donors#delete', :as => :delete_donor
  get 'donors/find_by_name'
  post "donors/found"
  ########## Donors end #####################

  ########## Projects #####################
  match 'projects' => 'projects#index'
  match 'create_new_project' => 'projects#new'
  match 'projects_search' => 'projects#search'
  post "projects/create"
  match 'project_details/:id' => 'projects#show', :as => :project_details
  post "projects/edit_project_details"
  match 'edit_project_details/:id' => 'projects#edit_project_details', :as => :edit_project_details
  match 'delete_project/:id' => 'projects#delete', :as => :delete_project
  get 'projects/find_by_name'
  post "projects/found"
  ########## Projects end #####################

  ########## Suppliers #####################
  match 'suppliers' => 'suppliers#index'
  match 'create_new_supplier' => 'suppliers#new'
  match 'supplier_search' => 'suppliers#search'
  post "suppliers/create"
  match 'supplier_details/:id' => 'suppliers#show', :as => :supplier_details
  match 'edit_supplier_details/:id' => 'suppliers#edit', :as => :edit_supplier_details
  post "suppliers/edit"
  match 'delete_supplier/:id' => 'suppliers#delete', :as => :delete_supplier
  ########## Suppliers end #####################

  ########## Manufacturers #####################
  match 'manufacturers' => 'manufacturer#index'
  match 'create_new_manufacturer' => 'manufacturer#new'
  match 'manufacturers_search' => 'manufacturer#search'
  post "manufacturer/create"
  match 'manufacturer_details/:id' => 'manufacturer#show', :as => :manufacturer_details
  post "manufacturer/edit"
  match 'edit_manufacturer_details/:id' => 'manufacturer#edit', :as => :edit_manufacturer_details
  match 'delete_manufacturer/:id' => 'manufacturer#delete', :as => :delete_manufacturer
  ########## Projects end #####################

  ########## Assets #####################
  match 'assets' => 'assets#index'
  match 'create_new_asset' => 'assets#new'
  match 'asset_search' => 'assets#search'
  match 'asset_categories' => 'assets#search_categories'
  match 'create_new_category' => 'assets#new_category'
  match 'asset_states_search' => 'assets#states_search'
  match 'create_new_state' => 'assets#new_state'
  post "assets/create_category"
  post "assets/create_state"
  post "assets/create"
  match 'edit_asset/:id' => 'assets#edit', :as => :edit_asset
  post "assets/update"
  match 'delete_asset/:id' => 'assets#delete', :as => :delete_asset
  match 'asset_details/:id' => 'assets#show', :as => :asset_details
  match 'edit_asset_category/:id' => 'assets#show_asset_category', :as => :edit_asset_category
  post "assets/show_asset_category"
  match 'delete_asset_category/:id' => 'assets#delete_asset_category', :as => :delete_asset_category
  match 'edit_asset_state/:id' => 'assets#edit_asset_state', :as => :edit_asset_state
  match 'delete_asset_state/:id' => 'assets#delete_asset_state', :as => :delete_asset_state
  post "assets/edit_asset_state"
  match 'asset_live_search' => 'assets#live_search'
  match 'serial_number_generator' => 'assets#serial_number_generator'
  match '/find_by_barcode' => 'assets#find_by_barcode'
  post 'assets/search'
  match '/search_results' => 'assets#search_results'
  get 'assets/find_by_name'
  get 'assets/find_by_model'
  get 'assets/find_by_version'
  get 'assets/find_by_delivered_by'
  get 'assets/find_by_approved_by'
  get 'assets/approved_by_name'
  get 'assets/people_by_name'
  match 'barcode_print/:id' => 'assets#print_barcode'
  match 'print_asset_barcode/:id' => 'assets#print_asset_barcode'
  get "assets/tedit"
  match 'validate_serial_number/:id' => 'assets#validate_serial_number', :as => :validate_serial_number
  ########## Donors end #####################




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
  root :to => 'home#index'
end
