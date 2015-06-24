json.array!(@repairing_layers) do |repairing_layer|
  json.extract! repairing_layer, :id, :title, :description, :town, :owner, :repairs
  json.url repairing_layer_url(repairing_layer, format: :json)
end
