class BudgetFileRovPlanfactsController < BudgetFileRovsController

  protected

  def generate_budget_file taxonomy, file_name
    if taxonomy
      budget_file = BudgetFileRovPlanfact.find_or_create_by(taxonomy: taxonomy, name: file_name)
    else
      budget_file = BudgetFileRovPlanfact.new
    end

    budget_file
  end

end
