json.extract! @category, :title
json.id "#{@category.id}"
json.category_id "#{@category.category_id}"
json.position @category.position
