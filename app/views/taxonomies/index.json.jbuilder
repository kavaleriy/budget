json.array!(@taxonomies) do |taxonomy|
  json.extract! taxonomy, :id, :name, :taxonomies
  json.url taxonomy_url(taxonomy, format: :json)
end
