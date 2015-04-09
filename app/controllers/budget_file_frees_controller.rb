class BudgetFileFreesController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileFree.new
  end

end
