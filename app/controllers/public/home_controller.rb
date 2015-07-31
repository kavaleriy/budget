class Public::HomeController < ApplicationController
  layout 'application_public'

  include ControllerCaching

  before_action :set_calendar, only: [:calendar, :subscribe, :unsubscribe]


  def index
    @areas = Town.areas
    @towns = Town.cities
  end

  def budget
    @budgets = Taxonomy.all
  end

  def documents
    @documentation_documents = Documentation::Document
    @documentation_documents = @documentation_documents.where(:town.in => params["town_select"].split(',')) unless params["town_select"].blank?
    @documentation_documents = @documentation_documents.where(:branch.in => params["branch_select"]) unless params["branch_select"].blank?
    @documentation_documents = @documentation_documents.where(:yearFrom.lte => params["year"].to_i, :yearTo.gte => params["year"].to_i) unless params["year"].blank?
    @documentation_documents = @documentation_documents.where(:title => Regexp.new(".*"+params["q"]+".*")) unless params["q"].blank?

    @towns = use_cache do
      Town.all.reject{|town| town.documentation_documents.empty?}
    end

    binding.pry
  end

  def calendar
    @subscriber = @calendar.subscribers.where(:email => cookies['subscriber']).first unless cookies['subscriber'].nil?
  end

  def subscribe
    email = subscriber_params[:email]
    @subscriber = Subscriber.where(:email => email).first || Subscriber.new(:email => email)
    @calendar.subscribers << @subscriber if @calendar.subscribers.where(:email => @subscriber.email).empty?

    respond_to do |format|
      if @subscriber.save
        response.set_cookie('subscriber', @subscriber.email)
        format.js
      else
        format.json { render json: @subscriber.errors, status: :unprocessable_entity }
      end
    end
  end

  def unsubscribe
    @calendar.subscribers.delete(Subscriber.find(params[:subscriber_id]))
    @calendar.save
    response.delete_cookie('subscriber')
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end
