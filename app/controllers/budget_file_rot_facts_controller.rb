class BudgetFileRotFactsController < BudgetFileRotsController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRotFact.new
  end

end
