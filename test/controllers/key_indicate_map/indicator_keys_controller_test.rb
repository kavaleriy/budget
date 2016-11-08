require 'test_helper'

class KeyIndicateMap::IndicatorKeysControllerTest < ActionController::TestCase
  setup do
    @key_indicate_map_indicator_key = key_indicate_map_indicator_keys(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:key_indicate_map_indicator_keys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create key_indicate_map_indicator_key" do
    assert_difference('KeyIndicateMap::IndicatorKey.count') do
      post :create, key_indicate_map_indicator_key: {  }
    end

    assert_redirected_to key_indicate_map_indicator_key_path(assigns(:key_indicate_map_indicator_key))
  end

  test "should show key_indicate_map_indicator_key" do
    get :show, id: @key_indicate_map_indicator_key
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @key_indicate_map_indicator_key
    assert_response :success
  end

  test "should update key_indicate_map_indicator_key" do
    patch :update, id: @key_indicate_map_indicator_key, key_indicate_map_indicator_key: {  }
    assert_redirected_to key_indicate_map_indicator_key_path(assigns(:key_indicate_map_indicator_key))
  end

  test "should destroy key_indicate_map_indicator_key" do
    assert_difference('KeyIndicateMap::IndicatorKey.count', -1) do
      delete :destroy, id: @key_indicate_map_indicator_key
    end

    assert_redirected_to key_indicate_map_indicator_keys_path
  end
end
