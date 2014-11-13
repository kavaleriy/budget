class RevenuesController < BudgetFilesController
  # before_action :set_revenue, only: [:show, :edit, :editinfo, :update, :destroy]

  # GET /revenues
  # GET /revenues.json
  # def index
  #   # @revenues = Revenue.all
  # end

  # GET /revenues/1
  # GET /revenues/1.json
  # def show
  # end

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
    if budget_file_params[:file]
      file = upload_io budget_file_params[:file]

      @budget_file.title = budget_file_params[:title].empty? ? file[:name] : budget_file_params[:title]

      @budget_file.file = file[:path]
      @budget_file.load_file
    else
      @budget_file.title =  "Доходи: #{DateTime.now.strftime()}" if @budget_file.title.nil?
      @budget_file.rows = {}
      params[:rows].each{|k, v|
        @revenue.rows[k] = { :amount => v[:amount].to_i }
      }
    end

    @budget_file.prepare

    respond_to do |format|
      if @budget_file.save
        format.html { redirect_to @budget_file, notice: 'File was successfully uploaded.' }
        format.json { render :show, status: :created, location: @budget_file }
      else
        format.html { render :new }
        format.json { render json: @budget_file.errors, status: :unprocessable_entity }
      end
    end
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

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def budget_file_params
      params.require(:revenue).permit(:title, :file)
    end
end
