json.array!(@budget_files_expenses) do |budget_files_expense|
  json.extract! budget_files_expense, :id, :fund_type, :program_code, :program_code_name, :function_code, :function_code_name, :economic_code, :economic_code_name, :budget_plan, :budget_estimate, :total_done, :percent_done, :done_special_fund, :done_service, :done_other, :total_bank_account, :bank_special_fund, :bank_service, :bank_other
  json.url budget_files_expense_url(budget_files_expense, format: :json)
end
