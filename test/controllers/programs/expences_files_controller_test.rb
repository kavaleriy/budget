require 'test_helper'

class Programs::ExpencesFilesControllerTest < ActionController::TestCase
  setup do
    @programs_expences_file = programs_expences_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:programs_expences_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create programs_expences_file" do
    assert_difference('Programs::ExpencesFile.count') do
      post :create, programs_expences_file: {  }
    end

    assert_redirected_to programs_expences_file_path(assigns(:programs_expences_file))
  end

  test "should show programs_expences_file" do
    get :show, id: @programs_expences_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @programs_expences_file
    assert_response :success
  end

  test "should update programs_expences_file" do
    patch :update, id: @programs_expences_file, programs_expences_file: {  }
    assert_redirected_to programs_expences_file_path(assigns(:programs_expences_file))
  end

  test "should destroy programs_expences_file" do
    assert_difference('Programs::ExpencesFile.count', -1) do
      delete :destroy, id: @programs_expences_file
    end

    assert_redirected_to programs_expences_files_path
  end
end
