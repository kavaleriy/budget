class BudgetFileRotsController < BudgetFilesController
  # GET /revenues/upload
  def upload
    @budget_file = BudgetFileRot.new
  end

  # POST /revenues
  # POST /revenues.json
  def create
    @budget_file = BudgetFileRot.new

    super
  end

  private

  def budget_file_params
    params.require(:budget_file_rot).permit(:title, :path)
  end

end
