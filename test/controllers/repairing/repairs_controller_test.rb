require 'test_helper'

class Repairing::RepairsControllerTest < ActionController::TestCase
  setup do
    @repairing_repair = repairing_repairs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:repairing_repairs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create repairing_repair" do
    assert_difference('Repairing::Repair.count') do
      post :create, repairing_repair: { amount: @repairing_repair.amount, coordinates: @repairing_repair.coordinates, description: @repairing_repair.description, district: @repairing_repair.district, koatuu: @repairing_repair.koatuu, street: @repairing_repair.street, title: @repairing_repair.title }
    end

    assert_redirected_to repairing_repair_path(assigns(:repairing_repair))
  end

  test "should show repairing_repair" do
    get :show, id: @repairing_repair
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @repairing_repair
    assert_response :success
  end

  test "should update repairing_repair" do
    patch :update, id: @repairing_repair, repairing_repair: { amount: @repairing_repair.amount, coordinates: @repairing_repair.coordinates, description: @repairing_repair.description, district: @repairing_repair.district, koatuu: @repairing_repair.koatuu, street: @repairing_repair.street, title: @repairing_repair.title }
    assert_redirected_to repairing_repair_path(assigns(:repairing_repair))
  end

  test "should destroy repairing_repair" do
    assert_difference('Repairing::Repair.count', -1) do
      delete :destroy, id: @repairing_repair
    end

    assert_redirected_to repairing_repairs_path
  end
end
