require 'test_helper'

class Repairing::CategoriesControllerTest < ActionController::TestCase
  setup do
    @repairing_category = repairing_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:repairing_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create repairing_category" do
    assert_difference('Repairing::Category.count') do
      post :create, repairing_category: { img: @repairing_category.img, title: @repairing_category.title }
    end

    assert_redirected_to repairing_category_path(assigns(:repairing_category))
  end

  test "should show repairing_category" do
    get :show, id: @repairing_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @repairing_category
    assert_response :success
  end

  test "should update repairing_category" do
    patch :update, id: @repairing_category, repairing_category: { img: @repairing_category.img, title: @repairing_category.title }
    assert_redirected_to repairing_category_path(assigns(:repairing_category))
  end

  test "should destroy repairing_category" do
    assert_difference('Repairing::Category.count', -1) do
      delete :destroy, id: @repairing_category
    end

    assert_redirected_to repairing_categories_path
  end
end
