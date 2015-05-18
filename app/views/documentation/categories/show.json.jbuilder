json.extract! @documentation_category, :title, :preview_ico
json.id "#{@documentation_category.id}"
json.category_id "#{@documentation_category.category_id}"
json.position @documentation_category.position
