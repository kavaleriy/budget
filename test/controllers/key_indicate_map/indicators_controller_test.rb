require 'test_helper'

class KeyIndicateMap::IndicatorsControllerTest < ActionController::TestCase
  setup do
    @key_indicate_map_indicator = key_indicate_map_indicators(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:key_indicate_map_indicators)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create key_indicate_map_indicator" do
    assert_difference('KeyIndicateMap::Indicator.count') do
      post :create, key_indicate_map_indicator: {  }
    end

    assert_redirected_to key_indicate_map_indicator_path(assigns(:key_indicate_map_indicator))
  end

  test "should show key_indicate_map_indicator" do
    get :show, id: @key_indicate_map_indicator
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @key_indicate_map_indicator
    assert_response :success
  end

  test "should update key_indicate_map_indicator" do
    patch :update, id: @key_indicate_map_indicator, key_indicate_map_indicator: {  }
    assert_redirected_to key_indicate_map_indicator_path(assigns(:key_indicate_map_indicator))
  end

  test "should destroy key_indicate_map_indicator" do
    assert_difference('KeyIndicateMap::Indicator.count', -1) do
      delete :destroy, id: @key_indicate_map_indicator
    end

    assert_redirected_to key_indicate_map_indicators_path
  end
end
