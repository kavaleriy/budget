require 'test_helper'

class Documentation::BranchesControllerTest < ActionController::TestCase
  setup do
    @documentation_branch = documentation_branches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:documentation_branches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create documentation_branch" do
    assert_difference('Documentation::Branch.count') do
      post :create, documentation_branch: { name: @documentation_branch.name }
    end

    assert_redirected_to documentation_branch_path(assigns(:documentation_branch))
  end

  test "should show documentation_branch" do
    get :show, id: @documentation_branch
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @documentation_branch
    assert_response :success
  end

  test "should update documentation_branch" do
    patch :update, id: @documentation_branch, documentation_branch: { name: @documentation_branch.name }
    assert_redirected_to documentation_branch_path(assigns(:documentation_branch))
  end

  test "should destroy documentation_branch" do
    assert_difference('Documentation::Branch.count', -1) do
      delete :destroy, id: @documentation_branch
    end

    assert_redirected_to documentation_branches_path
  end
end
