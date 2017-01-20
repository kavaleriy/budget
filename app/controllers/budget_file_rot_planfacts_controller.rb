class BudgetFileRotPlanfactsController < BudgetFileRotsController

  protected

  def generate_budget_file taxonomy, file_name
    if taxonomy
      budget_file = BudgetFileRotPlanfact.find_or_create_by(taxonomy: taxonomy, name: file_name)
    else
      budget_file = BudgetFileRotPlanfact.new
    end

    budget_file
  end

end
