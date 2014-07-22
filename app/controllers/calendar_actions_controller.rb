class CalendarActionsController < ApplicationController
  before_action :set_calendar_action, only: [:show, :edit, :update, :destroy]
  before_action :set_colors_list, only: [:new, :edit ]

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

    def set_colors_list
      @colors = [
          ['bg_white',
           '#fff'
          ],

          ['bg_silver',
           '#f0f3f4'
          ],

          ['bg_black',
           '#2d353c'
          ],

          ['bg_black_darker',
           '#242a30'
          ],

          ['bg_black_lighter',
           '#575d63'
          ],

          ['bg_grey',
           '#b6c2c9'
          ],

          ['bg_grey_darker',
           '#929ba1'
          ],

          ['bg_grey_lighter',
           '#c5ced4'
          ],

          ['bg_red',
           '#ff5b57'
          ],

          ['bg_red_darker',
           '#cc4946'
          ],

          ['bg_red_lighter',
           '#ff7c79'
          ],

          ['bg_orange',
           '#f59c1a'
          ],

          ['bg_orange_darker',
           '#c47d15'
          ],

          ['bg_orange_lighter',
           '#f7b048'
          ],

          ['bg_yellow',
           '#e3fa3e'
          ],

          ['bg_yellow_darker',
           '#b6c832'
          ],

          ['bg_yellow_lighter',
           '#e9fb65'
          ],

          ['bg_green',
           '#00acac'
          ],

          ['bg_green_darker',
           '#008a8a'
          ],

          ['bg_green_lighter',
           '#33bdbd'
          ],

          ['bg_blue',
           '#348fe2'
          ],

          ['bg_blue_darker',
           '#2a72b5'
          ],

          ['bg_blue_lighter',
           '#5da5e8'
          ],

          ['bg_aqua',
           '#49b6d6'
          ],

          ['bg_aqua_darker',
           '#3a92ab'
          ],

          ['bg_aqua_lighter',
           '#6dc5de'
          ],

          ['bg_purple',
           '#727cb6'
          ],

          ['bg_purple_darker',
           '#5b6392'
          ],

          ['bg_purple_lighter',
           '#8e96c5'
          ]
      ]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def calendar_action_params
      params.require(:calendar_action).permit(:title, :icon, :description, :color, :type, :holder)
    end
end
