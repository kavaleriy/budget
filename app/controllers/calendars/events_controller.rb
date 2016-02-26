module Calendars
  class EventsController < ApplicationController
    include ApplicationHelper
    layout false

    before_action :set_calendar
    before_action :set_event, only: [:show, :edit, :update, :destroy]
    before_action :set_attachments, only: [:show]

    load_and_authorize_resource :calendar
    load_and_authorize_resource :event, :through => :calendar

    # GET /events
    # GET /events.json
    def index
      @events = @calendar.events.all
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @events }
      end
    end

    # GET /events/1
    # GET /events/1.json
    def show
      respond_to do |format|
        # format.html { render( partial: 'show') if request.xhr? }
        format.js
      end
    end

    # GET /events/indicator_file
    def new
      binding.pry
      all_day = params[:all_day] == "true"
      @event = @calendar.events.new(
          :starts_at => params[:starts_at],
          :ends_at => params[:ends_at],
          :all_day => all_day,
          :text_color => '#ffffff',
          :color => '#8cc0f1',
      )

      respond_to do |format|
        format.js
      end
    end

    # GET /events/1/edit
    def edit
      respond_to do |format|
        format.js
      end
    end

    # POST /events
    # POST /events.json
    def create
      @event = @calendar.events.new(event_params)
      binding.pry
      respond_to do |format|
        if @event.save
          format.json { render json: @event }
        else
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end


    # PATCH/PUT /events/1
    # PATCH/PUT /events/1.json
    def update
      respond_to do |format|
        if @event.update(event_params)
          format.json { render json: @event }
        else
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end


    # DELETE /events/1
    # DELETE /events/1.json
    def destroy
      @event.destroy
      respond_to do |format|
        format.json { head :no_content }
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.


    def get_attachment_path filename, event_id
      Rails.root.join('public', 'files', 'attachments', event_id, filename)
    end


    def set_calendar
      @calendar = Calendar.find(params[:calendar_id])
    end

    def set_event
      @event = @calendar.events.find(params[:id])
      @events = @calendar.events.all.where( :holder => @event.holder, :starts_at => @event.starts_at, :ends_at => @event.ends_at )
    end


    def set_attachments

      # @attachments = @event.event_attachments
      @attachments = {}
      @events.each{|event|
        @attachments[event.id] = event.event_attachments
      }
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:holder, :title, :icon, :description, :starts_at, :ends_at, :all_day, :text_color, :color,:action_type)
    end

  end
end