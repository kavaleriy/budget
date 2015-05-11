require 'test_helper'

class Documentation::DocumentsControllerTest < ActionController::TestCase
  setup do
    @documentation_document = documentation_documents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:documentation_documents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create documentation_document" do
    assert_difference('Documentation::Document.count') do
      post :create, documentation_document: { category: @documentation_document.category, description: @documentation_document.description, issued: @documentation_document.issued, path: @documentation_document.path, preview_ico: @documentation_document.preview_ico, title: @documentation_document.title }
    end

    assert_redirected_to documentation_document_path(assigns(:documentation_document))
  end

  test "should show documentation_document" do
    get :show, id: @documentation_document
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @documentation_document
    assert_response :success
  end

  test "should update documentation_document" do
    patch :update, id: @documentation_document, documentation_document: { category: @documentation_document.category, description: @documentation_document.description, issued: @documentation_document.issued, path: @documentation_document.path, preview_ico: @documentation_document.preview_ico, title: @documentation_document.title }
    assert_redirected_to documentation_document_path(assigns(:documentation_document))
  end

  test "should destroy documentation_document" do
    assert_difference('Documentation::Document.count', -1) do
      delete :destroy, id: @documentation_document
    end

    assert_redirected_to documentation_documents_path
  end
end
