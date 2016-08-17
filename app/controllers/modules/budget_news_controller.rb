module Modules
  class BudgetNewsController < AdminController
    before_action :set_budget_news, only: [:show, :edit, :update, :destroy]
    skip_before_action :check_admin_permission, only: [:show, :all_news]
    # before_action :check_admin_permission, except: [:show, :all_news]
    before_action :get_published_news, only: [:all_news]
    respond_to :html

    def index
      @budget_news = Modules::BudgetNews.all.page(params[:page]).order(news_date: :desc)

      respond_with(@budget_news)
    end

    def show
      @budgets_news = BudgetNews.get_last_news(10)
      @banners = Modules::Banner.get_publish_banners.order(order_banner: :desc)
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
      if @budget_news.save
        flash[:success] = t('budget_news.create.success')
        redirect_to @budget_news
      else
        render :new
      end
    end

    def update
      unless modules_budget_news_params[:img].blank?
         if BudgetNews.new(modules_budget_news_params).valid?
           @budget_news.delete_image_file!
         end
      end
      if @budget_news.update(modules_budget_news_params)
        flash[:success] = t('budget_news.update.success')
        redirect_to @budget_news
      else
        render :edit
      end
    end

    def destroy
      @budget_news.destroy
      flash[:success] = t('budget_news.destroy.success')
      respond_with(@budget_news)
    end

    def get_published_news
      @published_budget_news = Modules::BudgetNews.published_news
    end

    def all_news
      @budget_news = @published_budget_news.page(params[:page]).per(9).order(news_date: :desc) unless @published_budget_news.nil?
    end

    private

      def set_budget_news
        @budget_news = Modules::BudgetNews.find(params[:id])
      end

      def modules_budget_news_params
        params.require(:modules_budget_news).permit(:title, :news_text, :link, :img, :news_date, :published)
      end

  end
end