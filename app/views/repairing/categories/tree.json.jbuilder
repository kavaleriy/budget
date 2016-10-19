json.array!(@repairing_categories) do |repairing_category|
  json.id "#{repairing_category.id}"
  json.children Repairing::Category.where( :category_id => repairing_category.id ).present?
  json.text repairing_category.title
  json.type 'child'
  json.url repairing_category_url(repairing_category, format: :json)
end
