class BudgetFileRotFondsController < BudgetFilesController

  protected

  def generate_budget_file
    @budget_file = BudgetFileRotFond.new
  end

end
