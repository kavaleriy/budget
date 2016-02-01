module Modules
  class BudgetNewsController < ApplicationController
    before_action :set_budget_news, only: [:show, :edit, :update, :destroy]

    respond_to :html

    def index
      @budget_news = Modules::BudgetNews.all
      respond_with(@budget_news)
    end

    def show
      respond_with(@budget_news)
    end

    def new
      @budget_news = Modules::BudgetNews.new
      respond_with(@budget_news)
    end

    def edit
    end

    def create
      @budget_news = Modules::BudgetNews.new(modules_budget_news_params)
      @budget_news.save
      respond_with(@budget_news)
    end

    def update
      @budget_news.update(modules_budget_news_params)
      respond_with(@budget_news)
    end

    def destroy
      @budget_news.destroy
      respond_with(@budget_news)
    end

    private
      def set_budget_news
        @budget_news = Modules::BudgetNews.find(params[:id])
      end

      def modules_budget_news_params
        params.require(:modules_budget_news).permit(:title, :news_text, :link, :img, :news_date)
      end
  end
end