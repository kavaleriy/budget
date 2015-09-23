json.array!(@repairing_categories) do |repairing_category|
  # json.extract! documentation_category, :id
  json.id "#{repairing_category.id}"
  json.children Repairing::Category.where( :category_id => repairing_category.id ).present?
  json.text repairing_category.title
  json.position repairing_category.position
  json.url repairing_category_url(repairing_category, format: :json)
end
