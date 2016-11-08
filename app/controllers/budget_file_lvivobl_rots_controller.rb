class BudgetFileLvivoblRotsController < BudgetFileRotsController

  protected

  def generate_budget_file
    @budget_file = BudgetFileLvivoblRot.new
  end

end
