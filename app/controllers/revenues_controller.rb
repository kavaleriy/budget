class RevenuesController < BudgetFilesController
  before_action :set_revenue, only: [:show, :edit, :editinfo, :update, :destroy]

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
    @revenue.rows = {}
    Revenue.get_revenue_codes.keys.reject{|k| k.slice(5, 3) == '000'}.each { |key| @revenue.rows[key] = { amount: '' } }
  end

  # GET /revenues/upload
  def upload
    @revenue = Revenue.new
  end

  # GET /revenues/1/edit
  def edit
  end

  # GET /revenues/1/edit
  def editinfo
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
    tree_info = @revenue['tree_info'].deep_dup
    params[:description].each { |key, value| tree_info[key]['description'] = value } unless params['description'].nil?

    rows = @revenue['rows'].deep_dup
    params[:rows].each { |key, value| rows[key]['amount'] = value[:amount].to_i }  unless params[:rows].nil?

    @revenue.prepare

    respond_to do |format|
      if @revenue.update(revenue_params.merge({:tree_info => tree_info, :rows => rows}))
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
