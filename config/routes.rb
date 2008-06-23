ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  map.connect 'database/:id/:table/blank_remove',
              :controller   => 'database',
              :action       => 'blank_remove',
              :requirements => { :id     => /[0-9]{1,11}/,
                                 :table  => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/:id/:table/blank_insert',
              :controller   => 'database',
              :action       => 'blank_insert',
              :requirements => { :id     => /[0-9]{1,11}/,
                                 :table  => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/:id/blank_field',
              :controller   => 'database',
              :action       => 'blank_field',
              :requirements => { :id  => /[0-9]{1,11}/ }

  map.connect 'database/:id/edit',
              :controller   => 'home',
              :action       => 'edit_database',
              :requirements => { :id  => /[0-9]{1,11}/ }

  map.connect 'database/:id/del',
              :controller   => 'home',
              :action       => 'del_database',
              :requirements => { :id  => /[0-9]{1,11}/ }

  map.connect 'database/:id/:table/add',
              :controller   => 'database',
              :action       => 'add_fields',
              :requirements => {  :id     => /[0-9]{1,11}/,
                                  :table  => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/:id/:table/:pk/edit',
              :controller   => 'database',
              :action       => 'edit_row',
              :requirements => { :id    => /[0-9]{1,11}/,
                                 :table => /[\.0-9a-z\-_]{1,64}/,
                                 :pk    => /[0-9]{1,11}/ }

  map.connect 'database/:id/:table/:pk/del',
              :controller   => 'database',
              :action       => 'del_row',
              :requirements => { :id    => /[0-9]{1,11}/,
                                 :table => /[\.0-9a-z\-_]{1,64}/,
                                 :pk    => /[0-9]{1,11}/ }

  map.connect 'database/:id/:table/:field/edit',
              :controller   => 'database',
              :action       => 'edit_field',
              :requirements => { :id    => /[0-9]{1,11}/,
                                 :table => /[\.0-9a-z\-_]{1,64}/,
                                 :field => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/:id/:table/:field/del',
              :controller   => 'database',
              :action       => 'del_field',
              :requirements => {  :id     => /[0-9]{1,11}/,
                                  :table  => /[\.0-9a-z\-_]{1,64}/,
                                  :field  => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/export/:id',
              :controller   => 'database',
              :action       => 'export_table',
              :requirements => { :id    => /[0-9]{1,11}/,
                                 :table => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/:id/add',
              :controller   => 'database',
              :action       => 'add_table',
              :requirements => { :id  => /[0-9]{1,11}/ }

  map.connect 'database/:id/:table/edit',
              :controller   => 'database',
              :action       => 'edit_table',
              :requirements => { :id    => /[0-9]{1,11}/,
                                 :table => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/:id/:table/del',
              :controller   => 'database',
              :action       => 'del_table',
              :requirements => { :id    => /[0-9]{1,11}/,
                                 :table => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/:id/:table/browse/:page',
              :controller   => 'database',
              :action       => 'browse',
              :requirements => { :id    => /[0-9]{1,11}/,
                                 :table => /[\.0-9a-z\-_]{1,64}/,
                                 :page  => /[0-9]{1,11}/ }

  map.connect 'database/:id/:table/insert',
              :controller   => 'database',
              :action       => 'insert',
              :requirements => { :id    => /[0-9]{1,11}/,
                                 :table => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/:id/:table/browse',
             :controller   => 'database',
             :action       => 'browse',
             :requirements => { :id    => /[0-9]{1,11}/,
                                :table => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/:id/:table',
              :controller   => 'database',
              :action       => 'table',
              :requirements => { :id    => /[0-9]{1,11}/,
                                 :table => /[\.0-9a-z\-_]{1,64}/ }

  map.connect 'database/add',
              :controller   => 'home',
              :action       => 'add_database'

  map.connect 'database/:id',
              :controller   => 'database',
              :action       => 'index',
              :requirements => { :id  => /[0-9]{1,11}/ }

  map.connect 'logout',
              :controller   => 'login',
              :action       => 'logout'

  map.connect 'login',
              :controller   => 'login',
              :action       => 'login'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'home', :action => 'databases'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
