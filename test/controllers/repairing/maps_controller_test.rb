require 'test_helper'

class Repairing::MapsControllerTest < ActionController::TestCase
  setup do
    @repairing_map = repairing_maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:repairing_maps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create repairing_map" do
    assert_difference('Repairing::Map.count') do
      post :create, repairing_map: { title: @repairing_map.title, town: @repairing_map.town }
    end

    assert_redirected_to repairing_map_path(assigns(:repairing_map))
  end

  test "should show repairing_map" do
    get :show, id: @repairing_map
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @repairing_map
    assert_response :success
  end

  test "should update repairing_map" do
    patch :update, id: @repairing_map, repairing_map: { title: @repairing_map.title, town: @repairing_map.town }
    assert_redirected_to repairing_map_path(assigns(:repairing_map))
  end

  test "should destroy repairing_map" do
    assert_difference('Repairing::Map.count', -1) do
      delete :destroy, id: @repairing_map
    end

    assert_redirected_to repairing_maps_path
  end
end
