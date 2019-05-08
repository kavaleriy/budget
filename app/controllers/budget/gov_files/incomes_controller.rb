class Budget::GovFiles::IncomesController < AdminController
  before_action :set_budget_files_income, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @budget_gov_files_incomes = Budget::GovFiles::Income.all.page(params[:page])
    respond_with(@budget_files_incomes)
  end

  def show
    respond_with(@budget_files_income)
  end

  def new
    @budget_files_income = Budget::GovFiles::Income.new
    respond_with(@budget_files_income)
  end

  def create
    # Budget::GovFiles::Income.all.destroy
    # binding.pry
    Budget::Files::Parsers::Income.new(params[:budget_gov_files_income][:file], params[:budget_gov_files_income][:koatuu]).parse
    redirect_to budget_gov_files_incomes_path
  end

  def destroy
    @budget_files_income.destroy
    respond_with(@budget_files_income)
  end

  private
    def set_budget_files_income
      @budget_files_income = Budget::GovFiles::Income.find(params[:id])
    end
end
