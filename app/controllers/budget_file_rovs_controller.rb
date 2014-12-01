class BudgetFileRovsController < BudgetFilesController
  protected

  def get_budget_file
    BudgetFileRov.new
  end

  private

  def budget_file_params
    params.require(:budget_file_rov).permit(:title, :path)
  end

end
