require 'test_helper'

class Document::CategoriesControllerTest < ActionController::TestCase
  setup do
    @document_category = document_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:document_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create document_category" do
    assert_difference('Document::Category.count') do
      post :create, document_category: { preview_ico: @document_category.preview_ico, title: @document_category.title }
    end

    assert_redirected_to document_category_path(assigns(:document_category))
  end

  test "should show document_category" do
    get :show, id: @document_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @document_category
    assert_response :success
  end

  test "should update document_category" do
    patch :update, id: @document_category, document_category: { preview_ico: @document_category.preview_ico, title: @document_category.title }
    assert_redirected_to document_category_path(assigns(:document_category))
  end

  test "should destroy document_category" do
    assert_difference('Document::Category.count', -1) do
      delete :destroy, id: @document_category
    end

    assert_redirected_to document_categories_path
  end
end
