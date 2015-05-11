require 'test_helper'

class Documentation::CategoriesControllerTest < ActionController::TestCase
  setup do
    @documentation_category = documentation_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:documentation_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create documentation_category" do
    assert_difference('Documentation::Category.count') do
      post :create, documentation_category: { preview_ico: @documentation_category.preview_ico, title: @documentation_category.title }
    end

    assert_redirected_to documentation_category_path(assigns(:documentation_category))
  end

  test "should show documentation_category" do
    get :show, id: @documentation_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @documentation_category
    assert_response :success
  end

  test "should update documentation_category" do
    patch :update, id: @documentation_category, documentation_category: { preview_ico: @documentation_category.preview_ico, title: @documentation_category.title }
    assert_redirected_to documentation_category_path(assigns(:documentation_category))
  end

  test "should destroy documentation_category" do
    assert_difference('Documentation::Category.count', -1) do
      delete :destroy, id: @documentation_category
    end

    assert_redirected_to documentation_categories_path
  end
end
