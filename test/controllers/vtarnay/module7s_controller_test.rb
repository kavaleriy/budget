require 'test_helper'

class Vtarnay::Module7sControllerTest < ActionController::TestCase
  setup do
    @vtarnay_module7 = vtarnay_module7s(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vtarnay_module7s)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vtarnay_module7" do
    assert_difference('Vtarnay::Module7.count') do
      post :create, vtarnay_module7: {  }
    end

    assert_redirected_to vtarnay_module7_path(assigns(:vtarnay_module7))
  end

  test "should show vtarnay_module7" do
    get :show, id: @vtarnay_module7
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @vtarnay_module7
    assert_response :success
  end

  test "should update vtarnay_module7" do
    patch :update, id: @vtarnay_module7, vtarnay_module7: {  }
    assert_redirected_to vtarnay_module7_path(assigns(:vtarnay_module7))
  end

  test "should destroy vtarnay_module7" do
    assert_difference('Vtarnay::Module7.count', -1) do
      delete :destroy, id: @vtarnay_module7
    end

    assert_redirected_to vtarnay_module7s_path
  end
end
