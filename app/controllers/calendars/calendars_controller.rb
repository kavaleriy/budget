module Calendars

  class CalendarsController < ApplicationController

    layout 'application_admin'

    before_action :set_calendar, only: [:show, :edit, :update, :destroy]

    before_action :authenticate_user!, only: [:show, :edit]

    load_and_authorize_resource

    # GET /calendars
    # GET /calendars.json
    def index
      @calendars = view_context.get_calendars
    end

    # GET /calendars/1
    # GET /calendars/1.json
    def show
      # require 'to_xls-rails'
      # @city_actions = CalendarAction.where(:holder => '1').to_a
      # @city_actions.map{ |action| action.text_color = 'black' if action.text_color.blank?; }
      # @people_actions = CalendarAction.where(:holder => '2').to_a
      # @people_actions.map{ |action| action.text_color = 'black' if action.text_color.blank?; }

      cal_obj = CalendarAction.new  # for constant

      @folding_city_action = CalendarAction.action_by_type(cal_obj.get_folding_type).action_city.to_a
      @analysis_city_action = CalendarAction.action_by_type(cal_obj.get_analysis_type).action_city.to_a
      @discussion_city_action = CalendarAction.action_by_type(cal_obj.get_discusion_type).action_city.to_a
      @execution_city_action = CalendarAction.action_by_type(cal_obj.get_execution_type).action_city.to_a

      @folding_people_action = CalendarAction.action_by_type(cal_obj.get_folding_type).action_people.to_a
      @analysis_people_action = CalendarAction.action_by_type(cal_obj.get_analysis_type).action_people.to_a
      @discussion_people_action = CalendarAction.action_by_type(cal_obj.get_discusion_type).action_people.to_a
      @execution_people_action = CalendarAction.action_by_type(cal_obj.get_execution_type).action_people.to_a

      respond_to do |format|
        format.html{}
        format.xls { send_data @calendar.to_xls() }
      end
    end


    # GET /calendars/indicator_file
    def new
      @calendar = Calendar.new
    end

    # GET /calendars/1/edit
    def edit
    end

    # POST /calendars
    # POST /calendars.json
    def create
      @calendar = Calendar.new(calendar_params)

      unless @calendar.import_file.nil?
        @calendar.import(params[:calendar][:import_file].tempfile)
        @calendar.title += " | Copy #{Date.current}"
      end

      unless current_user.nil?
        @calendar.author = current_user.email
        @calendar.town = current_user.town
      end

      respond_to do |format|
        if @calendar.save
          format.html { redirect_to [:calendars, @calendar], notice: t('calendar.create') }
          format.json { render :show, status: :created, location: @calendar }
        else
          format.html { render :new }
          format.json { render json: @calendar.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /calendars/1
    # PATCH/PUT /calendars/1.json
    def update
      new_params = calendar_params
      unless current_user.nil?
        new_params[:author] = current_user.email
        new_params[:town] = current_user.town
      end

      respond_to do |format|
        if @calendar.update(new_params)
          format.html { redirect_to calendars_calendars_url, notice: t('calendar.update') }
          format.json { render :show, status: :ok, location: calendars_calendars_url }
        else
          format.html { render :edit }
          format.json { render json: @calendar.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /calendars/1
    # DELETE /calendars/1.json
    def destroy
      @calendar.destroy
      respond_to do |format|
        format.html { redirect_to calendars_calendars_url, notice: t('calendar.delete') }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_calendar
        @calendar = Calendar.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def calendar_params
        params.require(:calendar).permit(:title, :description, :countdown_title, :countdown_date, :countdown_event, :import_file)
      end
  end
end
