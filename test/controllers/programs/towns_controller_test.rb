require 'test_helper'

class Programs::TownsControllerTest < ActionController::TestCase
  setup do
    @programs_town = programs_towns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:programs_towns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create programs_town" do
    assert_difference('Programs::Town.count') do
      post :create, programs_town: {  }
    end

    assert_redirected_to programs_town_path(assigns(:programs_town))
  end

  test "should show programs_town" do
    get :show, id: @programs_town
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @programs_town
    assert_response :success
  end

  test "should update programs_town" do
    patch :update, id: @programs_town, programs_town: {  }
    assert_redirected_to programs_town_path(assigns(:programs_town))
  end

  test "should destroy programs_town" do
    assert_difference('Programs::Town.count', -1) do
      delete :destroy, id: @programs_town
    end

    assert_redirected_to programs_towns_path
  end
end
