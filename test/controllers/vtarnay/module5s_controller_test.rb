require 'test_helper'

class Vtarnay::Module5sControllerTest < ActionController::TestCase
  setup do
    @vtarnay_module5 = vtarnay_module5s(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:vtarnay_module5s)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create vtarnay_module5" do
    assert_difference('Vtarnay::Module5.count') do
      post :create, vtarnay_module5: {  }
    end

    assert_redirected_to vtarnay_module5_path(assigns(:vtarnay_module5))
  end

  test "should show vtarnay_module5" do
    get :show, id: @vtarnay_module5
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @vtarnay_module5
    assert_response :success
  end

  test "should update vtarnay_module5" do
    patch :update, id: @vtarnay_module5, vtarnay_module5: {  }
    assert_redirected_to vtarnay_module5_path(assigns(:vtarnay_module5))
  end

  test "should destroy vtarnay_module5" do
    assert_difference('Vtarnay::Module5.count', -1) do
      delete :destroy, id: @vtarnay_module5
    end

    assert_redirected_to vtarnay_module5s_path
  end
end
