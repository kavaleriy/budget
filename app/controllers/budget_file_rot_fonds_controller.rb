class BudgetFileRotFondsController < BudgetFileRotsController
  protected

  def get_budget_file
    BudgetFileRotFond.new
  end

  private

  def budget_file_params
    params.require(:budget_file_rot_fond).permit(:title, :path, :data_type)
  end

end
