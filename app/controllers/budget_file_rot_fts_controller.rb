class BudgetFileRotFtsController < BudgetFileRotsController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRotFt.new
  end

end
