class RevenuesController < BudgetFilesController
  def show
  end

  # GET /revenues/new
  def new
    @budget_file = Revenue.new
    @budget_file.rows = []
    Revenue.get_revenue_codes.keys.reject{|k| k.slice(5, 3) == '000'}.each { |key| @budget_file.rows[key] = { amount: '' } }
  end

  # GET /revenues/upload
  def upload
    @budget_file = Revenue.new
  end

  # POST /revenues
  # POST /revenues.json
  def create
    @budget_file = Revenue.new()
    fname = budget_file_params[:file].original_filename
    @budget_file.taxonomy = TaxonomyRot.get_taxonomy(fname)
    @budget_file.title =  "Доходи: #{fname} - #{DateTime.now.strftime()}" if budget_file_params[:title].empty?

    super
  end

  private

  def budget_file_params
    params.require(:revenue).permit(:title, :file)
  end

end
