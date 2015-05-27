class BudgetFileRotFactsController < BudgetFilesRotsController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRotFact.new
  end

end
