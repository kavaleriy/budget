Rails.application.routes.draw do

  get 'budget_files/get_sunburst_data/:id' => 'budget_files#get_sunburst_data'
  get 'budget_files/get_bubbletree_data/:id' => 'budget_files#get_bubbletree_data'

  get 'budget_files/upload' => 'budget_files#upload'
  resources :budget_files

  resources :expenses

  get 'revenues/upload' => 'revenues#upload'
  get 'revenues/:id/editinfo' => 'revenues#editinfo'
  resources :revenues do
  end

  get 'visify/index'
  get 'visify/sunburst'
  get 'visify/sunburst_seq'
  get 'visify/bubbletree'
  get 'visify/bubblechart'
  get 'visify/circle_packing'
  get 'visify/treemap'
  get 'visify/force_collapsible'
  get 'visify/get_sunburst_data'
  get 'visify/get_bubbletree_data'

  get 'public/calendar/:calendar_id' => 'public#calendar'
  get 'public/pie_data'
  get 'public/timelinejs'

  post 'public/subscribe/:calendar_id' => 'public#subscribe'
  delete 'public/unsubscribe/:calendar_id/:subscriber_id' => 'public#unsubscribe'

  resources :calendars

  resources :calendar_actions

  resources :events

  resources :subscribers

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'public#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
