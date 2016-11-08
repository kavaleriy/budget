json.array!(@repairing_repairs) do |repairing_repair|
  json.extract! repairing_repair, :id, :title, :koatuu, :district, :street, :description, :amount, :coordinates
  json.url repairing_repair_url(repairing_repair, format: :json)
end
