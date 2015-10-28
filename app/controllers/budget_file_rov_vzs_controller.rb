class BudgetFileRovVzsController < BudgetFileRovsController
  protected

  def generate_budget_file
    @budget_file = BudgetFileRovVz.new
  end

end
