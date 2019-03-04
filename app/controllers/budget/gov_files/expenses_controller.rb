class Budget::GovFiles::ExpensesController < AdminController
  before_action :set_budget_files_expense, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @budget_gov_files_expenses = Budget::GovFiles::Expense.all.page(params[:page])
    respond_with(@budget_files_expenses)
  end

  def new
    @budget_files_expense = Budget::GovFiles::Expense.new
    respond_with(@budget_files_expense)
  end

  def create
    Budget::GovFiles::Expense.all.destroy
    Budget::Files::Parsers::Expense.new(params[:budget_gov_files_expense][:file], params[:budget_gov_files_expense][:koatuu]).parse
    redirect_to budget_gov_files_expenses_path
  end

  def destroy
    @budget_files_expense.destroy
    respond_with(@budget_files_expense)
  end

  private
    def set_budget_files_expense
      @budget_files_expense = Budget::GovFiles::Expense.find(params[:id])
    end
end
