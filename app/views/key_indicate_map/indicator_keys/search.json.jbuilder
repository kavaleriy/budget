json.array!(@keys) do |key|
    json.id "#{key.id}"
    json.text key.name
end