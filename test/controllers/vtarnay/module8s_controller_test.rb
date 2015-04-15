require 'test_helper'

class Vtarnay::Module8sControllerTest < ActionController::TestCase
  setup do
    @vtarnay_module8 = vtarnay_module8s(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vtarnay_module8s)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vtarnay_module8" do
    assert_difference('Vtarnay::Module8.count') do
      post :create, vtarnay_module8: {  }
    end

    assert_redirected_to vtarnay_module8_path(assigns(:vtarnay_module8))
  end

  test "should show vtarnay_module8" do
    get :show, id: @vtarnay_module8
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @vtarnay_module8
    assert_response :success
  end

  test "should update vtarnay_module8" do
    patch :update, id: @vtarnay_module8, vtarnay_module8: {  }
    assert_redirected_to vtarnay_module8_path(assigns(:vtarnay_module8))
  end

  test "should destroy vtarnay_module8" do
    assert_difference('Vtarnay::Module8.count', -1) do
      delete :destroy, id: @vtarnay_module8
    end

    assert_redirected_to vtarnay_module8s_path
  end
end
