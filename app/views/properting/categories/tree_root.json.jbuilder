json.array!(@categories) do |category|
  # json.extract! documentation_category, :id
  json.id "#{category.id}"
  json.children Properting::Category.where( :category_id => category.id ).present?
  json.text category.title
  json.position category.position
  json.type 'root'
  json.url properting_category_url(category, format: :json)
end
