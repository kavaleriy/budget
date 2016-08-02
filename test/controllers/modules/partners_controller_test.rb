require 'test_helper'

class Modules::PartnersControllerTest < ActionController::TestCase
  setup do
    @modules_partner = modules_partners(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:modules_partners)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create modules_partner" do
    assert_difference('Modules::Partner.count') do
      post :create, modules_partner: { name: @modules_partner.name, order_logo: @modules_partner.order_logo, publish_on: @modules_partner.publish_on }
    end

    assert_redirected_to modules_partner_path(assigns(:modules_partner))
  end

  test "should show modules_partner" do
    get :show, id: @modules_partner
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @modules_partner
    assert_response :success
  end

  test "should update modules_partner" do
    patch :update, id: @modules_partner, modules_partner: { name: @modules_partner.name, order_logo: @modules_partner.order_logo, publish_on: @modules_partner.publish_on }
    assert_redirected_to modules_partner_path(assigns(:modules_partner))
  end

  test "should destroy modules_partner" do
    assert_difference('Modules::Partner.count', -1) do
      delete :destroy, id: @modules_partner
    end

    assert_redirected_to modules_partners_path
  end
end
