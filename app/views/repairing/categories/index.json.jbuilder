json.array!(@repairing_categories) do |repairing_category|
  json.extract! repairing_category, :id, :title, :img
  json.url repairing_category_url(repairing_category, format: :json)
end
