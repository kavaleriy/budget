json.array!(@documentation_categories) do |documentation_category|
  # json.extract! documentation_category, :id
  json.id "#{documentation_category.id}"
  json.parent documentation_category.category_id
  json.text documentation_category.title
  json.url documentation_category_url(documentation_category, format: :json)
end
