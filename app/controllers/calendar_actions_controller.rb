class CalendarActionsController < ApplicationController
  layout 'application_admin'

  before_action :set_calendar_action, only: [:show, :edit, :update, :destroy]
  before_action :get_responsible, only: [:new, :edit]

  before_action :authenticate_user!, only: [:index, :edit]
  load_and_authorize_resource

  # GET /calendar_actions
  # GET /calendar_actions.json
  def index
    @city_actions = CalendarAction.city_actions
    @people_actions = CalendarAction.people_actions
  end

  # GET /calendar_actions/1
  # GET /calendar_actions/1.json
  def show
  end

  # GET /calendar_actions/indicator_file
  def new
    @calendar_action = CalendarAction.new({ holder: params[:holder], icon: params[:icon], text_color: '#999933', color: '#c7e0f8' })
  end

  # GET /calendar_actions/1/edit
  def edit
  end

  # POST /calendar_actions
  # POST /calendar_actions.json
  def create
    @calendar_action = CalendarAction.new(calendar_action_params)
    respond_to do |format|
      if @calendar_action.save
        format.html { redirect_to @calendar_action, notice: t('calendar_action.create') }
        format.json { render :show, status: :created, location: @calendar_action }
      else
        format.html { render :new }
        format.json { render json: @calendar_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /calendar_actions/1
  # PATCH/PUT /calendar_actions/1.json
  def update
    respond_to do |format|
      if @calendar_action.update(calendar_action_params)
        format.html { redirect_to @calendar_action, notice: t('calendar_action.update') }
        format.json { render :show, status: :ok, location: @calendar_action }
      else
        format.html { render :edit }
        format.json { render json: @calendar_action.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /calendar_actions/1
  # DELETE /calendar_actions/1.json
  def destroy
    @calendar_action.destroy
    respond_to do |format|
      format.html { redirect_to calendar_actions_url, notice: t('calendar_action.delete') }
      format.json { head :no_content }
    end
  end

  private

    def get_responsible
      @responsible = CalendarAction.pluck(:responsible).uniq.compact.sort
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_calendar_action
      @calendar_action = CalendarAction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def calendar_action_params
      params.require(:calendar_action).permit(:holder, :title, :icon, :description, :responsible, :text_color, :color, :action_type)
    end
end
