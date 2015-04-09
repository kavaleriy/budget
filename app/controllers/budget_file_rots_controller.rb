class BudgetFileRotsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRot.new
  end

end
