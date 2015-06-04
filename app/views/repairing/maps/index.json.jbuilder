json.array!(@repairing_maps) do |repairing_map|
  json.extract! repairing_map, :id, :title, :town
  json.url repairing_map_url(repairing_map, format: :json)
end
