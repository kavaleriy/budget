json.array!(@towns) do |town|
  json.extract! town, :id, :name
  json.url town_url(town, format: :json)
end
