require 'test_helper'

class Modules::SlidersControllerTest < ActionController::TestCase
  setup do
    @modules_slider = modules_sliders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:modules_sliders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create modules_slider" do
    assert_difference('Modules::Slider.count') do
      post :create, modules_slider: { img: @modules_slider.img, text: @modules_slider.text }
    end

    assert_redirected_to modules_slider_path(assigns(:modules_slider))
  end

  test "should show modules_slider" do
    get :show, id: @modules_slider
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @modules_slider
    assert_response :success
  end

  test "should update modules_slider" do
    patch :update, id: @modules_slider, modules_slider: { img: @modules_slider.img, text: @modules_slider.text }
    assert_redirected_to modules_slider_path(assigns(:modules_slider))
  end

  test "should destroy modules_slider" do
    assert_difference('Modules::Slider.count', -1) do
      delete :destroy, id: @modules_slider
    end

    assert_redirected_to modules_sliders_path
  end
end
