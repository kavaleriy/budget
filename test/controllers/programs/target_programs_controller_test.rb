require 'test_helper'

class Programs::TargetProgramsControllerTest < ActionController::TestCase
  setup do
    @programs_target_program = programs_target_programs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:programs_target_programs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create programs_target_program" do
    assert_difference('Programs::TargetProgram.count') do
      post :create, programs_target_program: {  }
    end

    assert_redirected_to programs_target_program_path(assigns(:programs_target_program))
  end

  test "should show programs_target_program" do
    get :show, id: @programs_target_program
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @programs_target_program
    assert_response :success
  end

  test "should update programs_target_program" do
    patch :update, id: @programs_target_program, programs_target_program: {  }
    assert_redirected_to programs_target_program_path(assigns(:programs_target_program))
  end

  test "should destroy programs_target_program" do
    assert_difference('Programs::TargetProgram.count', -1) do
      delete :destroy, id: @programs_target_program
    end

    assert_redirected_to programs_target_programs_path
  end
end
