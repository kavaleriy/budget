require 'test_helper'

class KeyIndicateMap::IndicatorFilesControllerTest < ActionController::TestCase
  setup do
    @key_indicate_map_indicator_file = key_indicate_map_indicator_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:key_indicate_map_indicator_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create key_indicate_map_indicator_file" do
    assert_difference('KeyIndicateMap::IndicatorFile.count') do
      post :create, key_indicate_map_indicator_file: {  }
    end

    assert_redirected_to key_indicate_map_indicator_file_path(assigns(:key_indicate_map_indicator_file))
  end

  test "should show key_indicate_map_indicator_file" do
    get :show, id: @key_indicate_map_indicator_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @key_indicate_map_indicator_file
    assert_response :success
  end

  test "should update key_indicate_map_indicator_file" do
    patch :update, id: @key_indicate_map_indicator_file, key_indicate_map_indicator_file: {  }
    assert_redirected_to key_indicate_map_indicator_file_path(assigns(:key_indicate_map_indicator_file))
  end

  test "should destroy key_indicate_map_indicator_file" do
    assert_difference('KeyIndicateMap::IndicatorFile.count', -1) do
      delete :destroy, id: @key_indicate_map_indicator_file
    end

    assert_redirected_to key_indicate_map_indicator_files_path
  end
end
