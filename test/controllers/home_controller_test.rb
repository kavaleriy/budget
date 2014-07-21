require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get pie_data" do
    get :pie_data
    assert_response :success
  end

end
