class BudgetFileRotVdsController < BudgetFileRotsController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRotVd.new
  end

end
