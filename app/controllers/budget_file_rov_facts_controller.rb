class BudgetFileRovFactsController < BudgetFilesController
  protected

  def generate_budget_file
    @budget_file = BudgetFileRovFact.new
  end

end
