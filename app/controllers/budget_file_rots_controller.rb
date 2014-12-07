class BudgetFileRotsController < BudgetFilesController
  protected

  def get_budget_file
    BudgetFileRot.new
  end

  private

  def budget_file_params
    params.require(:budget_file_rot).permit(:title, :path, :data_type)
  end

end
