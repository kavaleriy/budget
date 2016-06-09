module Public
  class HomeController < ApplicationController
    include ControllerCaching

#    before_action :set_calendar, only: [:calendar, :subscribe, :unsubscribe]


    def index
      @sliders = Modules::Slider.get_slider_by_order
      @news = Modules::BudgetNews.get_last_news(4)
      @test_town = Town.get_test_town.first
    end

    def about
    end

    def show_pages
      @page = ContentManager::PageContainer.get_page_by_alias(params[:alias]).first
    end

    # ===== Delete it method after upgrade new design ====== #
    def demo_index
      @sliders = Modules::Slider.get_slider_by_order
      @budgets_news = Modules::BudgetNews.get_last_news(7)

      # Render news design at layouts/new_design.html.haml
      # render layout: 'new_design'
      render 'public/home/new_design/demo_index', layout: 'new_design'
    end

    def demo_profile
      # @test_town = Town.get_test_town.first

      # Render news design at layouts/new_design.html.haml
      # render layout: 'new_design'
      render 'public/home/new_design/demo_profile', layout: 'town_profile'
    end

    def demo_repair_roads_map
      @town = Town.get_test_town.first
      # Render news design at layouts/new_design.html.haml
      # render layout: 'new_design'
      render 'public/home/new_design/repair_roads_map', layout: 'town_profile'
    end
    # ===== End. =========================================== #
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