json.array!(@towns) do |town|
  json.id "#{town.id}"
  json.value "#{town.title}"
end
