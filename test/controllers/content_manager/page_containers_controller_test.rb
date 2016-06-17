require 'test_helper'

class ContentManager::PageContainersControllerTest < ActionController::TestCase
  setup do
    @page_container = content_manager_page_containers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:content_manager_page_containers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create content_manager_page_container" do
    assert_difference('ContentManager::PageContainer.count') do
      post :create, page_container: {  }
    end

    assert_redirected_to content_manager_page_container_path(assigns(:page_container))
  end

  test "should show content_manager_page_container" do
    get :show, id: @page_container
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @page_container
    assert_response :success
  end

  test "should update content_manager_page_container" do
    patch :update, id: @page_container, page_container: {  }
    assert_redirected_to content_manager_page_container_path(assigns(:page_container))
  end

  test "should destroy content_manager_page_container" do
    assert_difference('ContentManager::PageContainer.count', -1) do
      delete :destroy, id: @page_container
    end

    assert_redirected_to content_manager_page_containers_path
  end
end
