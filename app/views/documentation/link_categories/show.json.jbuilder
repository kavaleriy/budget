json.extract! @documentation_link_category, :title, :preview_ico
json.id "#{@documentation_link_category.id}"
json.category_id "#{@documentation_link_category.link_category_id}"
json.position @documentation_link_category.position
