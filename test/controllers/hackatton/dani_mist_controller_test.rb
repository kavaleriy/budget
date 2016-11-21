require 'test_helper'

class Hackatton::DaniMistControllerTest < ActionController::TestCase
  test "should get load_data" do
    get :load_data
    assert_response :success
  end

end
