class BudgetFileRovsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRov.new
  end

end
