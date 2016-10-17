json.array!(@repairing_categories) do |repairing_category|
  json.id "#{repairing_category.id}"
  json.url repairing_category_url(repairing_category, format: :json)
end
