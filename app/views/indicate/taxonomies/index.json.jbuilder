json.array!(@indicate_taxonomies) do |indicate_taxonomy|
  json.extract! indicate_taxonomy, :id
  json.url indicate_taxonomy_url(indicate_taxonomy, format: :json)
end
