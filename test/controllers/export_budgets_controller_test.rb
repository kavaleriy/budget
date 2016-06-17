require 'test_helper'

class ExportBudgetsControllerTest < ActionController::TestCase
  setup do
    @export_budget = export_budgets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:export_budgets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create export_budget" do
    assert_difference('ExportBudget.count') do
      post :create, export_budget: { template: @export_budget.template, title: @export_budget.title, year: @export_budget.year }
    end

    assert_redirected_to export_budget_path(assigns(:export_budget))
  end

  test "should show export_budget" do
    get :show, id: @export_budget
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @export_budget
    assert_response :success
  end

  test "should update export_budget" do
    patch :update, id: @export_budget, export_budget: { template: @export_budget.template, title: @export_budget.title, year: @export_budget.year }
    assert_redirected_to export_budget_path(assigns(:export_budget))
  end

  test "should destroy export_budget" do
    assert_difference('ExportBudget.count', -1) do
      delete :destroy, id: @export_budget
    end

    assert_redirected_to export_budgets_path
  end
end
