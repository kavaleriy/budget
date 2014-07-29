class CalendarActionsController < ApplicationController
  before_action :set_calendar_action, only: [:show, :edit, :update, :destroy]

  # GET /calendar_actions
  # GET /calendar_actions.json
  def index
    @calendar_actions = CalendarAction.all

  end

  # GET /calendar_actions/1
  # GET /calendar_actions/1.json
  def show
  end

  # GET /calendar_actions/new
  def new
    @calendar_action = CalendarAction.new
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
        format.html { redirect_to @calendar_action, notice: 'Calendar action was successfully created.' }
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
        format.html { redirect_to @calendar_action, notice: 'Calendar action was successfully updated.' }
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
      format.html { redirect_to calendar_actions_url, notice: 'Calendar action was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_calendar_action
      @calendar_action = CalendarAction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def calendar_action_params
      params.require(:calendar_action).permit(:title, :icon, :description, :color, :type, :holder)
    end
end
