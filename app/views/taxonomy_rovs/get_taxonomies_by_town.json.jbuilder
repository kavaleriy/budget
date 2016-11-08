json.array! @taxonomies do |taxonomy|
  json.id taxonomy.id.to_s
  json.text taxonomy.title
end