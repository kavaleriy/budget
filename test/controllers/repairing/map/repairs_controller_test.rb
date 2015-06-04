require 'test_helper'

class Repairing::Map::RepairsControllerTest < ActionController::TestCase
  setup do
    @repairing_map_repair = repairing_map_repairs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:repairing_map_repairs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create repairing_map_repair" do
    assert_difference('Repairing::Map::Repair.count') do
      post :create, repairing_map_repair: { amount: @repairing_map_repair.amount, coordinates: @repairing_map_repair.coordinates, description: @repairing_map_repair.description, district: @repairing_map_repair.district, koatuu: @repairing_map_repair.koatuu, street: @repairing_map_repair.street, title: @repairing_map_repair.title }
    end

    assert_redirected_to repairing_map_repair_path(assigns(:repairing_map_repair))
  end

  test "should show repairing_map_repair" do
    get :show, id: @repairing_map_repair
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @repairing_map_repair
    assert_response :success
  end

  test "should update repairing_map_repair" do
    patch :update, id: @repairing_map_repair, repairing_map_repair: { amount: @repairing_map_repair.amount, coordinates: @repairing_map_repair.coordinates, description: @repairing_map_repair.description, district: @repairing_map_repair.district, koatuu: @repairing_map_repair.koatuu, street: @repairing_map_repair.street, title: @repairing_map_repair.title }
    assert_redirected_to repairing_map_repair_path(assigns(:repairing_map_repair))
  end

  test "should destroy repairing_map_repair" do
    assert_difference('Repairing::Map::Repair.count', -1) do
      delete :destroy, id: @repairing_map_repair
    end

    assert_redirected_to repairing_map_repairs_path
  end
end
