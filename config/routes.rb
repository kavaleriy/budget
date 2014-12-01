Rails.application.routes.draw do
  devise_for :users

  namespace :widgets do
    get 'visify/get_sunburst_data/:file_id' => 'visify#get_sunburst_data'
    get 'visify/get_bubbletree_data/:file_id' => 'visify#get_bubbletree_data'
    get 'visify/get_icicle_data/:file_id' => 'visify#get_icicle_data'
    get 'visify/sunburst/:file_id' => 'visify#sunburst'
    get 'visify/sunburst_seq/:file_id' => 'visify#sunburst_seq'
    get 'visify/bubbletree/:file_id' => 'visify#bubbletree'
    get 'visify/circles/:file_id' => 'visify#circles'
    get 'visify/treemap/:file_id' => 'visify#treemap'
    get 'visify/icicle/:file_id' => 'visify#icicle'
    get 'visify/collapsible/:file_id' => 'visify#collapsible'

    get 'calendar/pie_data/:calendar_id' => 'calendar#pie_data'
    get 'calendar/timelinejs_data/:calendar_id' => 'calendar#timelinejs_data'
  end


  get 'budget_files/upload' => 'budget_files#upload'
  get 'budget_files/:id/editinfo' => 'budget_files#editinfo'

  get 'budget_file_rots/upload' => 'budget_file_rots#upload'
  get 'budget_file_rovs/upload' => 'budget_file_rovs#upload'
  get 'budget_file_rot_fonds/upload' => 'budget_file_rot_fonds#upload'
  get 'budget_file_rov_fonds/upload' => 'budget_file_rov_fonds#upload'
  resources :budget_files
  resources :budget_file_rots
  resources :budget_file_rovs
  resources :budget_file_rot_fonds
  resources :budget_file_rov_fonds


  get 'public/calendar/:calendar_id' => 'public#calendar'

  post 'public/subscribe/:calendar_id' => 'public#subscribe'
  delete 'public/unsubscribe/:calendar_id/:subscriber_id' => 'public#unsubscribe'

  resources :calendars do
    resources :events
  end

  resources :calendar_actions


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
