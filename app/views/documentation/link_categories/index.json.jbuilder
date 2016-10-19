json.array!(@documentation_link_categories) do |documentation_link_category|
  # json.extract! documentation_category, :id
  json.id "#{documentation_link_category.id}"
  json.url documentation_link_category_url(documentation_link_category, format: :json)
end
