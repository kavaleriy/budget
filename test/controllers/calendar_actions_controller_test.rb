require 'test_helper'

class CalendarActionsControllerTest < ActionController::TestCase
  setup do
    @calendar_action = calendar_actions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:calendar_actions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create calendar_action" do
    assert_difference('CalendarAction.count') do
      post :create, calendar_action: { background: @calendar_action.background, description: @calendar_action.description, icon: @calendar_action.icon, title: @calendar_action.title, type: @calendar_action.type }
    end

    assert_redirected_to calendar_action_path(assigns(:calendar_action))
  end

  test "should show calendar_action" do
    get :show, id: @calendar_action
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @calendar_action
    assert_response :success
  end

  test "should update calendar_action" do
    patch :update, id: @calendar_action, calendar_action: { background: @calendar_action.background, description: @calendar_action.description, icon: @calendar_action.icon, title: @calendar_action.title, type: @calendar_action.type }
    assert_redirected_to calendar_action_path(assigns(:calendar_action))
  end

  test "should destroy calendar_action" do
    assert_difference('CalendarAction.count', -1) do
      delete :destroy, id: @calendar_action
    end

    assert_redirected_to calendar_actions_path
  end
end
