class BudgetFileLvivoblRovsController < BudgetFileRovsController

  protected

  def generate_budget_file
    @budget_file = BudgetFileLvivoblRov.new
  end

end
