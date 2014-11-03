class RevenuesController < BudgetFilesController
  before_action :set_revenue, only: [:show, :edit, :edit_bubbletree_info, :update, :destroy]

  # GET /revenues
  # GET /revenues.json
  def index
    @revenues = Revenue.all
  end

  # GET /revenues/1
  # GET /revenues/1.json
  def show
  end

  # GET /revenues/new
  def new
    @revenue = Revenue.new
  end

  # GET /revenues/1/edit
  def edit
  end
  # GET /revenues/1/edit_bubbletree
  def edit_bubbletree_info
  end

  # POST /revenues
  # POST /revenues.json
  def create
    @budget_file = Revenue.new()

    super revenue_params
  end

  # PATCH/PUT /revenues/1
  # PATCH/PUT /revenues/1.json
  def update
    if params['description'].nil?
      bubble_tree_info = nil
    else
      bubble_tree_info = @revenue['bubble_tree_info'].deep_dup
      params['description'].reject { |key, value| value.empty? }.each do |key, value|
        bubble_tree_info[key]['description'] = value
      end
    end

    par = revenue_params
    par = par.merge({:bubble_tree_info => bubble_tree_info}) unless bubble_tree_info.nil?

    respond_to do |format|
      if @revenue.update(par)
        format.html { redirect_to @revenue, notice: 'Revenue was successfully updated.' }
        format.json { render :show, status: :ok, location: @revenue }
      else
        format.html { render :edit }
        format.json { render json: @revenue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /revenues/1
  # DELETE /revenues/1.json
  def destroy
    @revenue.destroy
    respond_to do |format|
      format.html { redirect_to budget_files_url, notice: 'Revenue was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_revenue
      @revenue = Revenue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def revenue_params
      params.require(:revenue).permit(:title, :file)
    end
end
