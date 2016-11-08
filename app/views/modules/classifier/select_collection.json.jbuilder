json.array!(@items) do |item|
  json.id item.edrpou
  json.text item.pnaz
end
