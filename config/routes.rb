Rails.application.routes.draw do

  namespace :community do
    get 'geo_json' => 'communities#geo_json'
    resources :communities
  end

  namespace :repairing do
    resources :categories
  end

  namespace :key_indicate_map do
    resources :indicators
    resources :indicator_files
    resources :indicator_keys
    get 'indicators/geo_json/:type' => 'indicators#geo_json'
    get 'indicators/get/keys' => 'indicators#get_keys'
    get 'indicators/:year/:key' => 'indicators#index'
    put 'indicator_files/update_town/:id/:old_town' => 'indicator_files#update_town'
    put 'indicator_files/update_key/:id/:old_key' => 'indicator_files#update_key'
  end

  namespace :key_indicate do
    resources :indicator_files
    get 'indicator_files/get_files/:town' => 'indicator_files#get_files'
    get 'indicator_files/add_files/:town' => 'indicator_files#add_files'
    post 'indicator_files/get_vars' => 'indicator_files#get_vars'
    post 'indicator_files/reset_table/:year' => 'indicator_files#reset_table'
    post 'indicator_files/indicator_file_create' => 'indicator_files#indicator_file_create'
    put 'indicator_files/indicator_file_update/:indicator_file_id' => 'indicator_files#indicator_file_update'
    delete 'indicator_files/indicator_file_destroy/:indicator_file_id' => 'indicator_files#indicator_file_destroy'
    resources :dictionaries
    post 'dictionaries/:id/dictionary_file_create' => 'dictionaries#dictionary_file_create'
    put 'dictionaries/:id/dictionary_file_update/:dictionary_file_id' => 'dictionaries#dictionary_file_update'
    delete 'dictionaries/:id/dictionary_file_destroy/:dictionary_file_id' => 'dictionaries#dictionary_file_destroy'
    delete 'dictionaries/destroy_key/:key_id' => 'dictionaries#destroy_key'
  end

  get 'editor/index'

  namespace :programs do
    resources :indicator_files
  end

  namespace :programs do
    resources :towns
    resources :target_programs
    resources :expences_files
    resources :attachments
    get 'load' => 'target_programs#load'
    get 'load_expences/:town' => 'target_programs#load_expences'
    get 'load_indicators/:town' => 'target_programs#load_indicators'
    get 'towns/branch_report/:id' => 'towns#branch_report'
    post 'target_programs/create' => 'target_programs#create'
    get 'target_programs/list/:town' => 'target_programs#list'
    get 'target_programs/change_list/:town/:year' => 'target_programs#change_list'
    get 'target_programs/show_indicators/:id' => 'target_programs#show_indicators'
    put 'towns/update_custom/:id' => 'towns#update_custom'
    delete 'expences_files/:id' => 'expences_files#destroy'
    delete 'towns/expences_file_destroy/:expences_file_id' => 'towns#expences_file_destroy'
    delete 'towns/indicator_file_destroy/:indicator_file_id' => 'towns#indicator_file_destroy'
    delete 'target_programs/attachment_destroy/:attachment_id' => 'target_programs#attachment_destroy'
  end

  namespace :indicate do
    resources :taxonomies
    resources :indicators
    resources :indicator_files

    get 'taxonomies/indicators/:id' => 'taxonomies#indicators'
    get 'taxonomies/get_taxonomy/:town' => 'taxonomies#get_taxonomy'
    post 'taxonomies/:id/get_indicators' => 'taxonomies#get_indicators'
    get 'indicator_files/get_files/:town' => 'indicator_files#get_files'
  end

  namespace :documentation do
    get 'search_branch' => 'branches#search'
    resources :branches
    resources :categories
    get 'categories_tree_root' => 'categories#tree_root'
    get 'categories_tree' => 'categories#tree'
    resources :link_categories
    get 'link_categories_tree_root' => 'link_categories#tree_root'
    get 'link_categories_tree' => 'link_categories#tree'
    resources :documents
    resources :links
    put 'documents/lock/:id' => 'documents#lock'
  end


  get 'search_town' => 'towns#search'
  get 'search_indicator_key' => 'key_indicate_map/indicator_keys#search'
  get 'search_for_documents_town' => 'towns#search_for_documents'
  get 'search_for_towns_town' => 'towns#search_for_towns'
  resources :towns

  namespace :repairing do
    get 'map' => 'maps#show'
    get 'geo_json' => 'maps#geo_json'

    resources :layers do
      member do
        get 'geo_json'
        post 'create_repair_by_addr'
      end

      resources :repairs
    end
  end

  resources :sankeys

  devise_for :users
  resources :users , only: [:index, :show, :edit, :update, :destroy]

  namespace :widgets do
    get 'visify/visify/:file_id' => 'visify#visify'
    get 'visify/type/:file_id/:type' => 'visify#type', as: 'visify_type'
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
    get 'calendar/get_parent_event/:calendar_id/:event_id' => 'calendar#get_parent_event'
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
  resources :budget_file_lvivobl_rots
  resources :budget_file_lvivobl_rovs
  resources :budget_file_rots
  resources :budget_file_rot_planfacts
  resources :budget_file_rovs
  resources :budget_file_rot_fonds
  resources :budget_file_rov_fonds
  resources :budget_file_rot_facts
  resources :budget_file_rov_facts
  resources :budget_file_rov_planfacts

  get 'static/budget_file_help' => 'static#budget_file_help'
  get 'static/key_indicator_file_help' => 'static#key_indicator_file_help'
  get 'static/get_dictionary' => 'static#get_dictionary'


  #post 'calendars/:calendar_id/events/:id' => 'events#upload_files'
  post 'calendars/:calendar_id/events/:id/attachments/:attachment_id' => 'events#update_files_description'
  delete 'calendars/:calendar_id/events/:id/attachments/:attachment_id' => 'events#delete_attachments'
  get 'calendars/:calendar_id/events/:id/attachments/:attachment_id' => 'events#download_attachments'

  get 'taxonomies/show_modify/:id' => 'taxonomies#show_modify'
  post 'taxonomies/:taxonomy_id/edit' => 'taxonomies#upload_files'
  post 'taxonomies/:taxonomy_id/edit/taxonomy_attachments/:attachment_id' => 'taxonomies#update_files_description'
  delete 'taxonomies/:taxonomy_id/edit/taxonomy_attachments/:attachment_id' => 'taxonomies#delete_attachments'
  get 'taxonomies/:taxonomy_id/taxonomy_attachments/:attachment_id' => 'taxonomies#download_attachments'
  delete 'taxonomies/attachment_destroy/:attachment_id' => 'taxonomies#attachment_destroy'
  put 'taxonomies/attachment_update/:attachment_id' => 'taxonomies#attachment_update'
  post 'taxonomies/:id/attachment_create' => 'taxonomies#attachment_create'

  namespace :calendars do
    resources :calendars do
      resources :events do
        resources :event_attachments
      end
    end
  end
  resources :calendar_actions


  resources :subscribers


  namespace :public do
    get 'budget' => 'home#budget'

    get 'documents' => 'documents#index'


    get 'towns/:town_id' => 'towns#show'
    get 'ukraine_geo_json' => 'towns#geo_json'
    get 'ukraine_geo_json_town' => 'towns#geo_json_town'
  end

  get 'public/calendar/:calendar_id' => 'public#calendar'
  get 'public/documents                                                 ' => 'public/documents#index'
  get 'public/documents/check_auth' => 'public#check_auth'
  post 'public/subscribe/:calendar_id' => 'public#subscribe'
  delete 'public/unsubscribe/:calendar_id/:subscriber_id' => 'public#unsubscribe'

  get 'taxonomies/town_profile/:town_id' => 'taxonomies#town_profile'
  get 'programs/towns/town_profile/:town_id' => 'programs/target_programs#town_profile'
  get 'key_indicate_map/indicators/get/town_profile/:town_id' => 'key_indicate_map/indicators#index'
  get 'calendars/calendars/town_profile/:town_id' => 'public#town_profile'
  get 'sankeys/town_profile/:town_id' => 'sankeys#town_profile'
  get 'repairing/map/town_profile/:town_id' => 'repairing/map/town_profile#town_profile'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'public/home#index'

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
