class BudgetFileRotPlanfactsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRotPlanfact.new
  end

end
