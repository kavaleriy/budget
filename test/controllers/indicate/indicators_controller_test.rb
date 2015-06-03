require 'test_helper'

class Indicate::IndicatorsControllerTest < ActionController::TestCase
  setup do
    @indicate_indicator = indicate_indicators(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:indicate_indicators)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create indicate_indicator" do
    assert_difference('Indicate::Indicator.count') do
      post :create, indicate_indicator: {  }
    end

    assert_redirected_to indicate_indicator_path(assigns(:indicate_indicator))
  end

  test "should show indicate_indicator" do
    get :show, id: @indicate_indicator
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @indicate_indicator
    assert_response :success
  end

  test "should update indicate_indicator" do
    patch :update, id: @indicate_indicator, indicate_indicator: {  }
    assert_redirected_to indicate_indicator_path(assigns(:indicate_indicator))
  end

  test "should destroy indicate_indicator" do
    assert_difference('Indicate::Indicator.count', -1) do
      delete :destroy, id: @indicate_indicator
    end

    assert_redirected_to indicate_indicators_path
  end
end
