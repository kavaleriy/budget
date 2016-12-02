json.array!(@modules_partners_categories) do |modules_partners_category|
  json.extract! modules_partners_category, :id, :title, :alias
  json.url modules_partners_category_url(modules_partners_category, format: :json)
end
