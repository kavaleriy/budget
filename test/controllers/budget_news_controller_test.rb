require 'test_helper'

class BudgetNewsControllerTest < ActionController::TestCase
  setup do
    @budget_news = budget_news(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:budget_news)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create budget_news" do
    assert_difference('BudgetNews.count') do
      post :create, budget_news: { img: @budget_news.img, link: @budget_news.link, news_date: @budget_news.news_date, news_text: @budget_news.news_text, title: @budget_news.title }
    end

    assert_redirected_to budget_news_path(assigns(:budget_news))
  end

  test "should show budget_news" do
    get :show, id: @budget_news
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @budget_news
    assert_response :success
  end

  test "should update budget_news" do
    patch :update, id: @budget_news, budget_news: { img: @budget_news.img, link: @budget_news.link, news_date: @budget_news.news_date, news_text: @budget_news.news_text, title: @budget_news.title }
    assert_redirected_to budget_news_path(assigns(:budget_news))
  end

  test "should destroy budget_news" do
    assert_difference('BudgetNews.count', -1) do
      delete :destroy, id: @budget_news
    end

    assert_redirected_to budget_news_index_path
  end
end
