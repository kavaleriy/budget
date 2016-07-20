class PublicController < ApplicationController
  before_action :set_calendar, only: [:calendar, :subscribe, :unsubscribe]

  def index
  end

  def budget
    @budgets = Taxonomy.all
  end

  def calendar
    @subscriber = @calendar.subscribers.where(:email => cookies['subscriber']).first unless cookies['subscriber'].nil?

    @curr_town_event = @calendar.events.where(holder: 1, :starts_at.lte => Date.current).last
    @curr_people_event = @calendar.events.where(holder: 2, :starts_at.lte => Date.current).last

    render "widgets/calendar/calendar_box"
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

  def check_auth
    if !anyone_signed_in?
      deny_access
    else
      redirect_to public_documents_path
    end
  end

  def town_profile

    town = Town.find(params[:town_id])
    @calendar = Calendar.where(:town => town.title).first

    @subscriber = @calendar.subscribers.where(:email => cookies['subscriber']).first unless cookies['subscriber'].nil?
    respond_to do |format|
      format.html{render 'widgets/calendar/calendar_box'}
      format.js { render 'public/towns/calendar/calendar'}
    end

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
