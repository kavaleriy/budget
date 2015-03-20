require 'test_helper'

class SankeysControllerTest < ActionController::TestCase
  setup do
    @sankey = sankeys(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sankeys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sankey" do
    assert_difference('Sankey.count') do
      post :create, sankey: {  }
    end

    assert_redirected_to sankey_path(assigns(:sankey))
  end

  test "should show sankey" do
    get :show, id: @sankey
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sankey
    assert_response :success
  end

  test "should update sankey" do
    patch :update, id: @sankey, sankey: {  }
    assert_redirected_to sankey_path(assigns(:sankey))
  end

  test "should destroy sankey" do
    assert_difference('Sankey.count', -1) do
      delete :destroy, id: @sankey
    end

    assert_redirected_to sankeys_path
  end
end
