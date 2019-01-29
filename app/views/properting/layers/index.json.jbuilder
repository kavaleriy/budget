json.array!(@properting_layers) do |properting_layer|
  json.extract! properting_layer, :id, :title, :description, :town, :owner, :properties
  json.url properting_layer_url(properting_layer, format: :json)
end
