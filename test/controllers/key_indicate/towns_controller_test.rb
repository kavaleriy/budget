require 'test_helper'

class KeyIndicate::TownsControllerTest < ActionController::TestCase
  setup do
    @key_indicate_town = key_indicate_towns(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:key_indicate_towns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create key_indicate_town" do
    assert_difference('KeyIndicate::Town.count') do
      post :create, key_indicate_town: {  }
    end

    assert_redirected_to key_indicate_town_path(assigns(:key_indicate_town))
  end

  test "should show key_indicate_town" do
    get :show, id: @key_indicate_town
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @key_indicate_town
    assert_response :success
  end

  test "should update key_indicate_town" do
    patch :update, id: @key_indicate_town, key_indicate_town: {  }
    assert_redirected_to key_indicate_town_path(assigns(:key_indicate_town))
  end

  test "should destroy key_indicate_town" do
    assert_difference('KeyIndicate::Town.count', -1) do
      delete :destroy, id: @key_indicate_town
    end

    assert_redirected_to key_indicate_towns_path
  end
end
