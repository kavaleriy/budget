module Modules
  class BudgetNewsController < AdminController
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
      if validate_date modules_budget_news_params['news_date']
        unless modules_budget_news_params[:img].blank?
          @budget_news.delete_image_file!
        end
        @budget_news.update(modules_budget_news_params)
      end

      respond_with(@budget_news)
    end

    def destroy
      @budget_news.destroy
      respond_with(@budget_news)
    end

    private
      def validate_date(date)
        regExp = Regexp.new /^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$/
        result = regExp.match(date)
        if result
          str = Date.parse date
          if str.is_a?(Date)
            return true
          end
        else
          if @budget_news
            @budget_news.errors.add(:news_date, t('activerecord.attributes.invalid.date'))
            return false
          end
        end

      end



      def set_budget_news
        @budget_news = Modules::BudgetNews.find(params[:id])
      end

      def modules_budget_news_params
        params.require(:modules_budget_news).permit(:title, :news_text, :link, :img, :news_date)
      end


  end
end