class ExportBudgetsController < ApplicationController
  # layout 'visify', only: [:show]
  # skip_before_action :verify_authenticity_token,only: [:create_pdf]

  before_action :set_export_budget, only: [:show, :edit, :update, :destroy, :create_pdf]
  before_action :get_town_calendar, only: [:show, :edit, :update, :destroy, :create_pdf]
  before_action :set_export_budget_presenter, only: [:edit,:new]
  # GET /export_budgets
  # GET /export_budgets.json
  def index
    @export_budgets = ExportBudget.all
  end

  # GET /export_budgets/1
  # GET /export_budgets/1.json
  def show
    respond_to do |format|
      format.html
      format.pdf {
        render pdf: @export_budget.title,
               formats: [:html],
               template: 'export_budgets/create_pdf.html.haml',
               show_as_html: params.key?('debug')
                  }
    end
  end

  def create_pdf
    margin_size = 5
    # count page length
    # get all pages array size
    # minus 1 it is content array in pages array
    # plus content array size
    page_length = (@export_budget.pages.size - 1) + @export_budget.pages[:content].size
    render pdf: @export_budget.title,
           formats: [:html],
           dpi: '300',
           margin: {   top:               margin_size,                     # default 10 (mm)
                       bottom:            margin_size,
                       left:              margin_size,
                       right:             margin_size },
           template: 'export_budgets/create_pdf',
           show_as_html: params.key?('debug'),
           :footer => {
               :content => render_to_string(:template => 'export_budgets/footer.pdf.erb',locals: {page_length: page_length})
           }
  end

  # GET /export_budgets/new
  def new
    @export_budget = ExportBudget.new
    @export_budget.town = Town.get_user_town(current_user)
    @export_budget.set_default_pages
  end

  # GET /export_budgets/1/edit
  def edit
    @export_budget = ExportBudget.find(params[:id])
  end

  # POST /export_budgets
  # POST /export_budgets.json
  def create
    @export_budget = ExportBudget.new(export_budget_params)
    @export_budget.author = current_user
    respond_to do |format|
      if @export_budget.save
        format.html { redirect_to @export_budget, notice: 'Export budget was successfully created.' }
        format.js { }
        format.json { render :back, status: :created, location: @export_budget }
      else
        format.html { render :new }
        format.js { }
        format.json { render json: @export_budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /export_budgets/1
  # PATCH/PUT /export_budgets/1.json
  def update
    respond_to do |format|
      if @export_budget.update(export_budget_params)
        format.html { redirect_to @export_budget, notice: 'Export budget was successfully updated.' }
        format.json { render :show, status: :ok, location: @export_budget }
      else
        format.html { render :edit }
        format.json { render json: @export_budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /export_budgets/1
  # DELETE /export_budgets/1.json
  def destroy
    @export_budget.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Export budget was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def get_bubbletree_url_by_taxonomy_rot
      taxonomy_rot = TaxonomyRot.owned_by(@town_calendar.town).first
      "#{request.base_url}/widgets/visify/bubbletree/#{taxonomy_rot.id}"
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_export_budget
      @export_budget = ExportBudget.find(params[:id])
    end
    def set_export_budget_presenter
      @presenter = ExportBudget::FormPresenter.new(current_user,params[:locale])
    end
    def get_town_calendar
      # -binding.pry
      @town_calendar = Calendar.where(:town => @export_budget.town.title).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def export_budget_params
      # params.require(:export_budget).permit(:year, :title,:town,:pages => [:title_page,:content_page,:last_page,:content => [:public_budget]])
      params.require(:export_budget).permit!
    end
end
