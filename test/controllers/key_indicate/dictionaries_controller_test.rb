require 'test_helper'

class KeyIndicate::DictionariesControllerTest < ActionController::TestCase
  setup do
    @key_indicate_dictionary = key_indicate_dictionaries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:key_indicate_dictionaries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create key_indicate_dictionary" do
    assert_difference('KeyIndicate::Dictionary.count') do
      post :create, key_indicate_dictionary: {  }
    end

    assert_redirected_to key_indicate_dictionary_path(assigns(:key_indicate_dictionary))
  end

  test "should show key_indicate_dictionary" do
    get :show, id: @key_indicate_dictionary
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @key_indicate_dictionary
    assert_response :success
  end

  test "should update key_indicate_dictionary" do
    patch :update, id: @key_indicate_dictionary, key_indicate_dictionary: {  }
    assert_redirected_to key_indicate_dictionary_path(assigns(:key_indicate_dictionary))
  end

  test "should destroy key_indicate_dictionary" do
    assert_difference('KeyIndicate::Dictionary.count', -1) do
      delete :destroy, id: @key_indicate_dictionary
    end

    assert_redirected_to key_indicate_dictionaries_path
  end
end
