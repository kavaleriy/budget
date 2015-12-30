json.array!(@export_budgets) do |export_budget|
  json.extract! export_budget, :id, :year, :title, :template
  json.url export_budget_url(export_budget, format: :json)
end
