class BudgetFileRovPlanfactsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRovPlanfact.new
  end

  def set_budget_file_data_type
    @budget_file.data_type = nil
  end

end
