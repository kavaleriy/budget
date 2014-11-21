class ExpensesController < BudgetFilesController
  def show
  end

  # GET /expenses/new
  def new
    @expense = Expense.new
  end

  # GET /expenses/1/upload
  def upload
    @budget_file = Expense.new
  end

  # POST /expenses
  # POST /expenses.json
  def create
    @budget_file = Expense.new()
    @budget_file.owner_email = current_user.email unless current_user.nil?
    if budget_file_params[:file]
      file = upload_io budget_file_params[:file]

      @budget_file.title = budget_file_params[:title].empty? ? file[:name] : budget_file_params[:title]

      @budget_file.file = file[:path]
      @budget_file.load_file
    else
      @budget_file.title =  "Expense: #{DateTime.now.strftime()}" if @budget_file.title.nil?
      @budget_file.rows = {}
      params[:rows].each{|k, v|
        @revenue.rows[k] = { :amount => v[:amount].to_i }
      }
    end

    @budget_file.prepare

    respond_to do |format|
      if @budget_file.save
        format.html { redirect_to @budget_file, notice: 'Дані успішно завантажені.' }
        format.json { render :show, status: :created, location: @budget_file }
      else
        format.html { render :new }
        format.json { render json: @budget_file.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def budget_file_params
      params.require(:expense).permit(:title, :file)
    end
end
