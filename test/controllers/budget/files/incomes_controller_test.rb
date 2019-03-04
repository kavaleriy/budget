require 'test_helper'

class Budget::Files::IncomesControllerTest < ActionController::TestCase
  setup do
    @budget_files_income = budget_files_incomes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:budget_files_incomes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create budget_files_income" do
    assert_difference('Budget::Files::Income.count') do
      post :create, budget_files_income: { budget_estimate: @budget_files_income.budget_estimate, budget_plan: @budget_files_income.budget_plan, fund_type: @budget_files_income.fund_type, income_code: @budget_files_income.income_code, income_code_name: @budget_files_income.income_code_name, percent_done: @budget_files_income.percent_done, total_done: @budget_files_income.total_done }
    end

    assert_redirected_to budget_files_income_path(assigns(:budget_files_income))
  end

  test "should show budget_files_income" do
    get :show, id: @budget_files_income
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @budget_files_income
    assert_response :success
  end

  test "should update budget_files_income" do
    patch :update, id: @budget_files_income, budget_files_income: { budget_estimate: @budget_files_income.budget_estimate, budget_plan: @budget_files_income.budget_plan, fund_type: @budget_files_income.fund_type, income_code: @budget_files_income.income_code, income_code_name: @budget_files_income.income_code_name, percent_done: @budget_files_income.percent_done, total_done: @budget_files_income.total_done }
    assert_redirected_to budget_files_income_path(assigns(:budget_files_income))
  end

  test "should destroy budget_files_income" do
    assert_difference('Budget::Files::Income.count', -1) do
      delete :destroy, id: @budget_files_income
    end

    assert_redirected_to budget_files_incomes_path
  end
end
