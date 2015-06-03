require 'test_helper'

class BudgetFilesControllerTest < ActionController::TestCase
  setup do
    @budget_file = budget_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:budget_files)
  end

  test "should get indicator_file" do
    get :indicator_file
    assert_response :success
  end

  test "should create budget_file" do
    assert_difference('BudgetFile.count') do
      post :create, budget_file: { file: @budget_file.file, title: @budget_file.title }
    end

    assert_redirected_to budget_file_path(assigns(:budget_file))
  end

  test "should show budget_file" do
    get :show, id: @budget_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @budget_file
    assert_response :success
  end

  test "should update budget_file" do
    patch :update, id: @budget_file, budget_file: { file: @budget_file.file, title: @budget_file.title }
    assert_redirected_to budget_file_path(assigns(:budget_file))
  end

  test "should destroy budget_file" do
    assert_difference('BudgetFile.count', -1) do
      delete :destroy, id: @budget_file
    end

    assert_redirected_to budget_files_path
  end
end
