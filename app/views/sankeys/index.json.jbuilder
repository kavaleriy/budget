json.array!(@sankeys) do |sankey|
  json.extract! sankey, :id
  json.url sankey_url(sankey, format: :json)
end
