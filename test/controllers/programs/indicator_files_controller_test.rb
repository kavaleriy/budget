require 'test_helper'

class Programs::IndicatorFilesControllerTest < ActionController::TestCase
  setup do
    @programs_indicator_file = programs_indicator_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:programs_indicator_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create programs_indicator_file" do
    assert_difference('Programs::IndicatorFile.count') do
      post :create, programs_indicator_file: {  }
    end

    assert_redirected_to programs_indicator_file_path(assigns(:programs_indicator_file))
  end

  test "should show programs_indicator_file" do
    get :show, id: @programs_indicator_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @programs_indicator_file
    assert_response :success
  end

  test "should update programs_indicator_file" do
    patch :update, id: @programs_indicator_file, programs_indicator_file: {  }
    assert_redirected_to programs_indicator_file_path(assigns(:programs_indicator_file))
  end

  test "should destroy programs_indicator_file" do
    assert_difference('Programs::IndicatorFile.count', -1) do
      delete :destroy, id: @programs_indicator_file
    end

    assert_redirected_to programs_indicator_files_path
  end
end
