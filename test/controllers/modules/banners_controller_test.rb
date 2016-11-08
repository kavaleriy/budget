require 'test_helper'

class Modules::BannersControllerTest < ActionController::TestCase
  setup do
    @modules_banner = modules_banners(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:modules_banners)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create modules_banner" do
    assert_difference('Modules::Banner.count') do
      post :create, modules_banner: { order_banner: @modules_banner.order_banner, publish_on: @modules_banner.publish_on, title: @modules_banner.title }
    end

    assert_redirected_to modules_banner_path(assigns(:modules_banner))
  end

  test "should show modules_banner" do
    get :show, id: @modules_banner
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @modules_banner
    assert_response :success
  end

  test "should update modules_banner" do
    patch :update, id: @modules_banner, modules_banner: { order_banner: @modules_banner.order_banner, publish_on: @modules_banner.publish_on, title: @modules_banner.title }
    assert_redirected_to modules_banner_path(assigns(:modules_banner))
  end

  test "should destroy modules_banner" do
    assert_difference('Modules::Banner.count', -1) do
      delete :destroy, id: @modules_banner
    end

    assert_redirected_to modules_banners_path
  end
end
