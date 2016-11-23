require 'test_helper'

class Modules::PartnersCategoriesControllerTest < ActionController::TestCase
  setup do
    @modules_partners_category = modules_partners_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:modules_partners_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create modules_partners_category" do
    assert_difference('Modules::PartnersCategory.count') do
      post :create, modules_partners_category: { alias: @modules_partners_category.alias, title: @modules_partners_category.title }
    end

    assert_redirected_to modules_partners_category_path(assigns(:modules_partners_category))
  end

  test "should show modules_partners_category" do
    get :show, id: @modules_partners_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @modules_partners_category
    assert_response :success
  end

  test "should update modules_partners_category" do
    patch :update, id: @modules_partners_category, modules_partners_category: { alias: @modules_partners_category.alias, title: @modules_partners_category.title }
    assert_redirected_to modules_partners_category_path(assigns(:modules_partners_category))
  end

  test "should destroy modules_partners_category" do
    assert_difference('Modules::PartnersCategory.count', -1) do
      delete :destroy, id: @modules_partners_category
    end

    assert_redirected_to modules_partners_categories_path
  end
end
