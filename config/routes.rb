Rails.application.routes.draw do

  namespace :documentation do
    resources :categories
    get 'categories_tree_root' => 'categories#tree_root'
    get 'categories_tree' => 'categories#tree'

    resources :documents
  end
  #resources :event_attachments
  #resources :event_attachments, :path => 'event_attachments'
  resources :towns

  namespace :vtarnay do
    resources :module7s
  end

  namespace :vtarnay do
    resources :module8s
  end

  namespace :vtarnay do
    resources :module5s
  end

  resources :sankeys

  devise_for :users
  resources :users , only: [:index, :show, :edit, :update, :destroy]

  namespace :vtarnay do
    get 'module2' => 'module2#index'
    get 'module2/:id' => 'module2#show'

    get 'module3' => 'module3#index'
    get 'module3/:id' => 'module3#show'

    get 'module4' => 'module4#index'
    get 'module4/:id' => 'module4#show'
    get 'module4/get_rows/:rov_file_id' => 'module4#get_rows'

    get 'module5s' => 'module5s#index'
    get 'module5s/new' => 'module5s#new'
    get 'module5s/:id' => 'module5s#show'
    get 'module5s/download/:id' => 'module5s#download'
  end

  namespace :widgets do
    get 'visify/get_bubbletree_data/:file_id' => 'visify#get_bubbletree_data'
    get 'visify/get_bubbletree_data/:file_id/:levels' => 'visify#get_bubbletree_data'
    get 'visify/get_bubblesubtree/:file_id/:taxonomy/:key' => 'visify#get_bubblesubtree'
    get 'visify/get_bubblesubtree_with_fact/:file_id/:taxonomy/:key' => 'visify#get_bubblesubtree_with_fact'
    get 'visify/get_bubbletree_nodedata/:file_id/:taxonomy/:key' => 'visify#get_bubbletree_nodedata'
    get 'visify/get_attachments/:file_id' => 'visify#get_attachments'
    get 'visify/get_visify_level/:file_id/:taxonomy' => 'visify#get_visify_level'

    get 'visify/sunburst/:file_id' => 'visify#sunburst'
    get 'visify/sunburst_seq/:file_id' => 'visify#sunburst_seq'
    get 'visify/sunburst_bilevel/:file_id' => 'visify#sunburst_bilevel'
    get 'visify/sunburst_zoomable/:file_id' => 'visify#sunburst_zoomable'
    get 'visify/bubbletree/:file_id' => 'visify#bubbletree'
    get 'visify/circles/:file_id' => 'visify#circles'
    get 'visify/treemap/:file_id' => 'visify#treemap'
    get 'visify/treemap_with_headers/:file_id' => 'visify#treemap_with_headers'
    get 'visify/icicle/:file_id' => 'visify#icicle'
    get 'visify/collapsible/:file_id' => 'visify#collapsible'

    get 'calendar/pie_data/:calendar_id' => 'calendar#pie_data'
    get 'calendar/timelinejs_data/:calendar_id' => 'calendar#timelinejs_data'
    get 'calendar/timelinejs/:calendar_id' => 'calendar#timelinejs'
    get 'calendar/pie_cycle/:calendar_id' => 'calendar#pie_cycle'
    get 'calendar/calendar/:calendar_id' => 'calendar#calendar'
  end

  get 'sankeys/get_rows/:rot_file_id/:rov_file_id' => 'sankeys#get_rows'
  get 'sankeys/sankey/:id' => 'sankeys#sankey'

  resources :taxonomies
  resources :taxonomy_frees
  resources :taxonomy_rots
  resources :taxonomy_rovs
  resources :taxonomy_rov_facts
  resources :taxonomy_rov_fact_zvits

  resources :budget_files do
    get 'download' => 'budget_files#download'
  end

  resources :budget_file_frees
  resources :budget_file_rots
  resources :budget_file_rot_planfacts
  resources :budget_file_rovs
  resources :budget_file_rot_fonds
  resources :budget_file_rov_fonds
  resources :budget_file_rot_facts
  resources :budget_file_rov_facts
  resources :budget_file_rov_planfacts

  get 'static/budget_file_help' => 'static#budget_file_help'


  get 'public/calendar/:calendar_id' => 'public#calendar'

  post 'public/subscribe/:calendar_id' => 'public#subscribe'
  #post 'calendars/:calendar_id/events/:id' => 'events#upload_files'
  post 'calendars/:calendar_id/events/:id/attachments/:attachment_id' => 'events#update_files_description'
  delete 'calendars/:calendar_id/events/:id/attachments/:attachment_id' => 'events#delete_attachments'
  delete 'public/unsubscribe/:calendar_id/:subscriber_id' => 'public#unsubscribe'
  get 'calendars/:calendar_id/events/:id/attachments/:attachment_id' => 'events#download_attachments'

  post 'taxonomies/:taxonomy_id/edit' => 'taxonomies#upload_files'
  post 'taxonomies/:taxonomy_id/edit/taxonomy_attachments/:attachment_id' => 'taxonomies#update_files_description'
  delete 'taxonomies/:taxonomy_id/edit/taxonomy_attachments/:attachment_id' => 'taxonomies#delete_attachments'
  get 'taxonomies/:taxonomy_id/taxonomy_attachments/:attachment_id' => 'taxonomies#download_attachments'

  resources :calendars do
    resources :events do
      resource :event_attachments
    end
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
