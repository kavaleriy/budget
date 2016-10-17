json.array!(@key_indicate_towns) do |key_indicate_town|
  json.extract! key_indicate_town, :id
  json.url key_indicate_town_url(key_indicate_town, format: :json)
end
