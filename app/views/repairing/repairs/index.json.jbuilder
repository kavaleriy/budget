json.array!(@repairing_map_repairs) do |repairing_map_repair|
  json.extract! repairing_map_repair, :id, :title, :koatuu, :district, :street, :description, :amount, :coordinates
  json.url repairing_map_repair_url(repairing_map_repair, format: :json)
end
