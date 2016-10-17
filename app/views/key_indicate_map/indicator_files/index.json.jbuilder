json.array!(@key_indicate_map_indicator_files) do |key_indicate_map_indicator_file|
  json.extract! key_indicate_map_indicator_file, :id
  json.url key_indicate_map_indicator_file_url(key_indicate_map_indicator_file, format: :json)
end
