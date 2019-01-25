json.array!(@properting_categories) do |properting_category|
  json.id "#{properting_category.id}"
  json.children Properting::Category.where( :category_id => properting_category.id ).present?
  json.text properting_category.title
  json.type 'child'
  json.url properting_category_url(properting_category, format: :json)
end
