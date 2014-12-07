class BudgetFileRovFondsController < BudgetFileRovsController
  protected

  def get_budget_file
    BudgetFileRovFond.new
  end

  private

  def budget_file_params
    params.require(:budget_file_rov_fond).permit(:title, :path, :data_type)
  end

end
