require 'test_helper'

class Indicate::IndicatorFilesControllerTest < ActionController::TestCase
  setup do
    @indicate_indicator_file = indicate_indicator_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:indicate_indicator_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create indicate_indicator_file" do
    assert_difference('Indicate::IndicatorFile.count') do
      post :create, indicate_indicator_file: {  }
    end

    assert_redirected_to indicate_indicator_file_path(assigns(:indicate_indicator_file))
  end

  test "should show indicate_indicator_file" do
    get :show, id: @indicate_indicator_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @indicate_indicator_file
    assert_response :success
  end

  test "should update indicate_indicator_file" do
    patch :update, id: @indicate_indicator_file, indicate_indicator_file: {  }
    assert_redirected_to indicate_indicator_file_path(assigns(:indicate_indicator_file))
  end

  test "should destroy indicate_indicator_file" do
    assert_difference('Indicate::IndicatorFile.count', -1) do
      delete :destroy, id: @indicate_indicator_file
    end

    assert_redirected_to indicate_indicator_files_path
  end
end
