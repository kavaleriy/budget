require 'test_helper'

class Repairing::LayersControllerTest < ActionController::TestCase
  setup do
    @repairing_layer = repairing_layers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:repairing_layers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create repairing_layer" do
    assert_difference('Repairing::Layer.count') do
      post :create, repairing_layer: { description: @repairing_layer.description, owner: @repairing_layer.owner, repairs: @repairing_layer.repairs, title: @repairing_layer.title, town: @repairing_layer.town }
    end

    assert_redirected_to repairing_layer_path(assigns(:repairing_layer))
  end

  test "should show repairing_layer" do
    get :show, id: @repairing_layer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @repairing_layer
    assert_response :success
  end

  test "should update repairing_layer" do
    patch :update, id: @repairing_layer, repairing_layer: { description: @repairing_layer.description, owner: @repairing_layer.owner, repairs: @repairing_layer.repairs, title: @repairing_layer.title, town: @repairing_layer.town }
    assert_redirected_to repairing_layer_path(assigns(:repairing_layer))
  end

  test "should destroy repairing_layer" do
    assert_difference('Repairing::Layer.count', -1) do
      delete :destroy, id: @repairing_layer
    end

    assert_redirected_to repairing_layers_path
  end
end
