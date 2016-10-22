json.array!(@key_indicate_map_indicators) do |key_indicate_map_indicator|
  json.extract! key_indicate_map_indicator, :id
  json.url key_indicate_map_indicator_url(key_indicate_map_indicator, format: :json)
end
