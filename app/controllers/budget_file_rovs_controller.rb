class BudgetFileRovsController < BudgetFilesController
  def upload
    @budget_file = BudgetFileRov.new
  end

  def create
    @budget_file = BudgetFileRov.new

    super
  end

  private

  def budget_file_params
    params.require(:budget_file_rov).permit(:title, :path)
  end

end
