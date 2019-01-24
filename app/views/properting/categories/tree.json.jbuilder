json.array!(@categories) do |category|
  json.id "#{category.id}"
  json.children Properting::Category.where( :category_id => category.id ).present?
  json.text category.title
  json.type 'child'
  json.url properting_category_url(category, format: :json)
end
