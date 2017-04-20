json.array!(@towns) do |town|
  json.id "#{town.id}"
  json.text town.to_s
end