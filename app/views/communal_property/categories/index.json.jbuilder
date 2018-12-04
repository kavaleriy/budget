json.array!(@categories) do |category|
  json.id "#{category.id}"
  json.url communal_property_category_url(category, format: :json)
end
