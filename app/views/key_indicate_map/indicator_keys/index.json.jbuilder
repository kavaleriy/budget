json.array!(@key_indicate_map_indicator_keys) do |key_indicate_map_indicator_key|
  json.extract! key_indicate_map_indicator_key, :id
  json.url key_indicate_map_indicator_key_url(key_indicate_map_indicator_key, format: :json)
end
