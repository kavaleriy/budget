json.array!(@categories) do |category|
  json.id "#{category.id}"
  json.url properting_category_url(category, format: :json)
end
