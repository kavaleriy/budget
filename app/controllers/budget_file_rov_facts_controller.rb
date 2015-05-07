class BudgetFileRovFactsController < BudgetFilesController
  protected

  def generate_budget_file
    @budget_file = BudgetFileRovFact.new
  end

  def set_budget_file_data_type
    @budget_file.data_type = :fact
  end

end
