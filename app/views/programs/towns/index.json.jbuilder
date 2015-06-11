json.array!(@programs_towns) do |programs_town|
  json.extract! programs_town, :id
  json.url programs_town_url(programs_town, format: :json)
end
