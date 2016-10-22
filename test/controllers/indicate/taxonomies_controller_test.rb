require 'test_helper'

class Indicate::TaxonomiesControllerTest < ActionController::TestCase
  setup do
    @indicate_taxonomy = indicate_taxonomies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:indicate_taxonomies)
  end

  test "should get indicator_file" do
    get :indicator_file
    assert_response :success
  end

  test "should create indicate_taxonomy" do
    assert_difference('Indicate::Taxonomy.count') do
      post :create, indicate_taxonomy: {  }
    end

    assert_redirected_to indicate_taxonomy_path(assigns(:indicate_taxonomy))
  end

  test "should show indicate_taxonomy" do
    get :show, id: @indicate_taxonomy
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @indicate_taxonomy
    assert_response :success
  end

  test "should update indicate_taxonomy" do
    patch :update, id: @indicate_taxonomy, indicate_taxonomy: {  }
    assert_redirected_to indicate_taxonomy_path(assigns(:indicate_taxonomy))
  end

  test "should destroy indicate_taxonomy" do
    assert_difference('Indicate::Taxonomy.count', -1) do
      delete :destroy, id: @indicate_taxonomy
    end

    assert_redirected_to indicate_taxonomies_path
  end
end
