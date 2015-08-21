json.array!(@documentation_link_categories) do |documentation_link_category|
  # json.extract! documentation_category, :id
  json.id "#{documentation_link_category.id}"
  json.children Documentation::LinkCategory.where( :link_category_id => documentation_link_category.id ).present?
  json.text documentation_link_category.title
  json.position documentation_link_category.position
  json.url documentation_link_category_url(documentation_link_category, format: :json)
end
