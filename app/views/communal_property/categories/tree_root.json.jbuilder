json.array!(@categories) do |category|
  # json.extract! documentation_category, :id
  json.id "#{category.id}"
  json.children CommunalProperty::Category.where( :category_id => category.id ).present?
  json.text category.title
  json.position category.position
  json.type 'root'
  json.url communal_property_category_url(category, format: :json)
end
