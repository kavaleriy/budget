class BudgetFileRotVzsController < BudgetFileRotsController

  protected

  def generate_budget_file taxonomy, file_name
    @budget_file = BudgetFileRotVz.new
  end

end
