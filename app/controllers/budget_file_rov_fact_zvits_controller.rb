class BudgetFileRovFactZvitsController < BudgetFilesController
  protected

  def generate_budget_file
    @budget_file = BudgetFileRovFactZvit.new
  end

end
