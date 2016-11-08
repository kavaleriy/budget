json.array!(@expenses) do |expense|
  json.extract! expense, :id, :title, :file
  json.url expense_url(expense, format: :json)
end
