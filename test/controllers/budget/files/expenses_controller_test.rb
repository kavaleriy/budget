require 'test_helper'

class Budget::Files::ExpensesControllerTest < ActionController::TestCase
  setup do
    @budget_files_expense = budget_files_expenses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:budget_files_expenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create budget_files_expense" do
    assert_difference('Budget::Files::Expense.count') do
      post :create, budget_files_expense: { bank_other: @budget_files_expense.bank_other, bank_service: @budget_files_expense.bank_service, bank_special_fund: @budget_files_expense.bank_special_fund, budget_estimate: @budget_files_expense.budget_estimate, budget_plan: @budget_files_expense.budget_plan, done_other: @budget_files_expense.done_other, done_service: @budget_files_expense.done_service, done_special_fund: @budget_files_expense.done_special_fund, economic_code: @budget_files_expense.economic_code, economic_code_name: @budget_files_expense.economic_code_name, function_code: @budget_files_expense.function_code, function_code_name: @budget_files_expense.function_code_name, fund_type: @budget_files_expense.fund_type, percent_done: @budget_files_expense.percent_done, program_code: @budget_files_expense.program_code, program_code_name: @budget_files_expense.program_code_name, total_bank_account: @budget_files_expense.total_bank_account, total_done: @budget_files_expense.total_done }
    end

    assert_redirected_to budget_files_expense_path(assigns(:budget_files_expense))
  end

  test "should show budget_files_expense" do
    get :show, id: @budget_files_expense
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @budget_files_expense
    assert_response :success
  end

  test "should update budget_files_expense" do
    patch :update, id: @budget_files_expense, budget_files_expense: { bank_other: @budget_files_expense.bank_other, bank_service: @budget_files_expense.bank_service, bank_special_fund: @budget_files_expense.bank_special_fund, budget_estimate: @budget_files_expense.budget_estimate, budget_plan: @budget_files_expense.budget_plan, done_other: @budget_files_expense.done_other, done_service: @budget_files_expense.done_service, done_special_fund: @budget_files_expense.done_special_fund, economic_code: @budget_files_expense.economic_code, economic_code_name: @budget_files_expense.economic_code_name, function_code: @budget_files_expense.function_code, function_code_name: @budget_files_expense.function_code_name, fund_type: @budget_files_expense.fund_type, percent_done: @budget_files_expense.percent_done, program_code: @budget_files_expense.program_code, program_code_name: @budget_files_expense.program_code_name, total_bank_account: @budget_files_expense.total_bank_account, total_done: @budget_files_expense.total_done }
    assert_redirected_to budget_files_expense_path(assigns(:budget_files_expense))
  end

  test "should destroy budget_files_expense" do
    assert_difference('Budget::Files::Expense.count', -1) do
      delete :destroy, id: @budget_files_expense
    end

    assert_redirected_to budget_files_expenses_path
  end
end
