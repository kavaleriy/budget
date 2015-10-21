class BudgetFileRovVdsController < BudgetFileRovsController
  protected

  def generate_budget_file
    @budget_file = BudgetFileRovVd.new
  end

end
