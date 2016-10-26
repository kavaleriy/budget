module Public
  class HomeController < ApplicationController
    include ControllerCaching

#    before_action :set_calendar, only: [:calendar, :subscribe, :unsubscribe]


    def index
      @sliders = Modules::Slider.get_slider_by_order
      @news = Modules::BudgetNews.published_news.get_last_news(3)
      @test_town = Town.get_test_town.first
      @info_pages = ContentManager::PageContainer.get_info_pages
      @partners = Modules::Partner.by_category(t('home.index.home')).get_publish_partners.order(order_logo: :asc)
    end

    def about
    end

    def show_pages
      @page = ContentManager::PageContainer.get_page_by_alias(params[:alias]).first
    end

    # def budget
    #   @budgets = Taxonomy.all
    # end
    #
    # def calendar
    #   @subscriber = @calendar.subscribers.where(:email => cookies['subscriber']).first unless cookies['subscriber'].nil?
    #
    # end

    # def subscribe
    #   email = subscriber_params[:email]
    #   @subscriber = Subscriber.where(:email => email).first || Subscriber.new(:email => email)
    #   @calendar.subscribers << @subscriber if @calendar.subscribers.where(:email => @subscriber.email).empty?
    #
    #   respond_to do |format|
    #     if @subscriber.save
    #       response.set_cookie('subscriber', @subscriber.email)
    #       format.js
    #     else
    #       format.json { render json: @subscriber.errors, status: :unprocessable_entity }
    #     end
    #   end
    # end
    #
    # def unsubscribe
    #   @calendar.subscribers.delete(Subscriber.find(params[:subscriber_id]))
    #   @calendar.save
    #   response.delete_cookie('subscriber')
    # end
    #
    # private
    #
    # def set_calendar
    #   @calendar = Calendar.find(params[:calendar_id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    # def subscriber_params
    #   params.require(:subscriber).permit(:email)
    # end
  end
end