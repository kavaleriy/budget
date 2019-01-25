json.array!(@properting_categories) do |properting_category|
  json.id "#{properting_category.id}"
  json.url properting_category_url(properting_category, format: :json)
end
