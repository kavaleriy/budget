json.array!(@keys) do |key|
    binding.pry
    json.id "#{key.id}"
    json.text key.to_s
end