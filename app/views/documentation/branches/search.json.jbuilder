json.array!(@branches) do |branch|
  json.id "#{branch.id}"
  json.text "#{branch.title}" || "#{branch.id}"
end
