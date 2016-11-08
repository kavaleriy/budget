require 'test_helper'

class Community::CommunitiesControllerTest < ActionController::TestCase
  setup do
    @community_community = community_communities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:community_communities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create community_community" do
    assert_difference('Community::Community.count') do
      post :create, community_community: {  }
    end

    assert_redirected_to community_community_path(assigns(:community_community))
  end

  test "should show community_community" do
    get :show, id: @community_community
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @community_community
    assert_response :success
  end

  test "should update community_community" do
    patch :update, id: @community_community, community_community: {  }
    assert_redirected_to community_community_path(assigns(:community_community))
  end

  test "should destroy community_community" do
    assert_difference('Community::Community.count', -1) do
      delete :destroy, id: @community_community
    end

    assert_redirected_to community_communities_path
  end
end
