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

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.resources :snippets
  map.index '/', :controller => 'snippets', :action => 'index'
  map.resources :users, :member => { :enable => :put } do |users|
    users.resources :roles
  end
  map.show_category '/topic/:name', :controller => 'snippets', :action => 'show_by_category'
  map.show_prediction '/predictions', :controller => 'snippets', :action => 'show_by_prediction'
  map.show_user '/user/:login', :controller => 'users', :action => 'show_by_login'
  map.show_snippet '/truth/:id', :controller => 'snippets', :action => 'show'
  map.new_snippet '/post', :controller => 'snippets', :action => 'new'
  map.forgot '/forgot', :controller => 'users', :action => 'forgot'
  map.reset 'reset/:reset_code', :controller => 'users', :action => 'reset'
  map.about '/about', :controller => 'static', :action => 'about'
  map.random '/rnd', :controller => 'snippets', :action => 'random'
  map.resources :categories do |categories|
      categories.resources :snippets
  end
  
 #   map.resources :categories, :collection => {:admin => :get} do |categories|
  #    categories.resources :snippets, :name_prefix => 'category'
  # end
end
