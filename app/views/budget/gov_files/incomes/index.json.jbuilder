json.array!(@budget_files_incomes) do |budget_files_income|
  json.extract! budget_files_income, :id, :fund_type, :income_code, :income_code_name, :budget_plan, :budget_estimate, :total_done, :percent_done
  json.url budget_files_income_url(budget_files_income, format: :json)
end
