class BudgetNewsController < ApplicationController
  before_action :set_budget_news, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @budget_news = BudgetNews.all
    respond_with(@budget_news)
  end

  def show
    respond_with(@budget_news)
  end

  def new
    @budget_news = BudgetNews.new
    respond_with(@budget_news)
  end

  def edit
  end

  def create
    @budget_news = BudgetNews.new(budget_news_params)
    @budget_news.save
    respond_with(@budget_news)
  end

  def update
    @budget_news.update(budget_news_params)
    respond_with(@budget_news)
  end

  def destroy
    @budget_news.destroy
    respond_with(@budget_news)
  end

  private
    def set_budget_news
      @budget_news = BudgetNews.find(params[:id])
    end

    def budget_news_params
      params.require(:budget_news).permit(:title, :news_text, :link, :img, :news_date)
    end
end
