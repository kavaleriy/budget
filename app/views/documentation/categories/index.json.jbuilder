json.array!(@documentation_categories) do |documentation_category|
  json.extract! documentation_category, :id, :title, :preview_ico
  json.url documentation_category_url(documentation_category, format: :json)
end
