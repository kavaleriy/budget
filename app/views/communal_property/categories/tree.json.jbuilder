json.array!(@categories) do |category|
  json.id "#{category.id}"
  json.children CommunalProperty::Category.where( :category_id => category.id ).present?
  json.text category.title
  json.type 'child'
  json.url communal_property_category_url(category, format: :json)
end
