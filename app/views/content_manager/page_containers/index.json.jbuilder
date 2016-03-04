json.array!(@content_manager_page_containers) do |content_manager_page_container|
  json.extract! content_manager_page_container, :id
  json.url content_manager_page_container_url(content_manager_page_container, format: :json)
end
