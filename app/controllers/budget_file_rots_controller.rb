class BudgetFileRotsController < BudgetFilesController
  # GET /revenues/upload
  def upload
    @budget_file = BudgetFileRot.new
  end

  # POST /revenues
  # POST /revenues.json
  def create
    @budget_file = BudgetFileRot.new()
    fname = budget_file_params[:file].original_filename
    @budget_file.taxonomy = TaxonomyRot.get_taxonomy(fname)
    @budget_file.title =  "Доходи: #{fname} - #{DateTime.now.strftime('%B')}" if budget_file_params[:title].empty?

    super
  end

  private

  def budget_file_params
    params.require(:revenue).permit(:title, :file)
  end

end
