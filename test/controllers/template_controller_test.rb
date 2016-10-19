require 'test_helper'

class TemplateControllerTest < ActionController::TestCase
  test "should get content" do
    get :content
    assert_response :success
  end

  test "should get title" do
    get :title
    assert_response :success
  end

end
