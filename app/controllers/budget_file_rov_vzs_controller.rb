class BudgetFileRovVzsController < BudgetFileRovsController
  protected

  def generate_budget_file taxonomy, file_name
    @budget_file = BudgetFileRovVz.new
  end

end
