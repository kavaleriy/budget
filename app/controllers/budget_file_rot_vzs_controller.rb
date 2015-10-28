class BudgetFileRotVzsController < BudgetFileRotsController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRotVz.new
  end

end
