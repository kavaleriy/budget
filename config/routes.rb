Rails.application.routes.draw do
  resources :sankeys

  devise_for :users

  get 'test/test_embed_code' # Not for production version!!!

  namespace :vtarnay do
    get 'module2' => 'module2#index'
    get 'module2/:id' => 'module2#show'

    get 'module3' => 'module3#index'
    get 'module3/:id' => 'module3#show'

    get 'module4' => 'module4#index'
    get 'module4/:id' => 'module4#show'
  end

  namespace :widgets do
    get 'visify/get_bubbletree_data/:file_id/:year/:month' => 'visify#get_bubbletree_data'
    get 'visify/get_bubbletree_nodedata/:file_id/:taxonomy/:key' => 'visify#get_bubbletree_nodedata'
    get 'visify/sunburst/:file_id' => 'visify#sunburst'
    get 'visify/sunburst_seq/:file_id' => 'visify#sunburst_seq'
    get 'visify/sunburst_bilevel/:file_id' => 'visify#sunburst_bilevel'
    get 'visify/sunburst_zoomable/:file_id' => 'visify#sunburst_zoomable'
    get 'visify/bubbletree/:file_id' => 'visify#bubbletree'
    get 'visify/circles/:file_id' => 'visify#circles'
    get 'visify/treemap/:file_id' => 'visify#treemap'
    get 'visify/icicle/:file_id' => 'visify#icicle'
    get 'visify/collapsible/:file_id' => 'visify#collapsible'

    get 'calendar/pie_data/:calendar_id' => 'calendar#pie_data'
    get 'calendar/timelinejs_data/:calendar_id' => 'calendar#timelinejs_data'
    get 'calendar/timelinejs/:calendar_id' => 'calendar#timelinejs'
    get 'calendar/pie_cycle/:calendar_id' => 'calendar#pie_cycle'
    get 'calendar/pie_cycle_for_embed/:calendar_id' => 'calendar#pie_cycle_for_embed'
    get 'calendar/calendar/:calendar_id' => 'calendar#calendar'
  end

  get 'sankeys/get_rows/:rot_file_id/:rov_file_id' => 'sankeys#get_rows'

  get 'budget_files/upload' => 'budget_files#upload'
  get 'budget_files/:id/editinfo' => 'budget_files#editinfo'

  get 'static/budget_file_help' => 'static#budget_file_help'

  get 'budget_file_rots/upload' => 'budget_file_rots#upload'
  get 'budget_file_rovs/upload' => 'budget_file_rovs#upload'
  get 'budget_file_rot_fonds/upload' => 'budget_file_rot_fonds#upload'
  get 'budget_file_rov_fonds/upload' => 'budget_file_rov_fonds#upload'
  resources :taxonomies
  resources :taxonomy_rots
  resources :taxonomy_rot_fonds
  resources :taxonomy_rovs
  resources :taxonomy_rov_fonds

  resources :budget_files
  resources :budget_file_rots
  resources :budget_file_rovs
  resources :budget_file_rot_fonds
  resources :budget_file_rov_fonds


  get 'public/calendar/:calendar_id' => 'public#calendar'

  post 'public/subscribe/:calendar_id' => 'public#subscribe'
  post 'calendars/:calendar_id/events/:id' => 'events#upload_files'
  post 'calendars/:calendar_id/events/:id/attachments/:attachment_id' => 'events#update_files_description'
  delete 'calendars/:calendar_id/events/:id/attachments/:attachment_id' => 'events#delete_attachments'
  delete 'public/unsubscribe/:calendar_id/:subscriber_id' => 'public#unsubscribe'
  get 'calendars/:calendar_id/events/:id/attachments/:attachment_id' => 'events#download_attachments'
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
