class Indicate::IndicatorsController < ApplicationController
  layout 'application_admin'
  before_action :set_indicate_indicator, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /indicate/indicators
  # GET /indicate/indicators.json
  def index
    @indicate_indicators = Indicate::Indicator.all
  end

  # GET /indicate/indicators/1
  # GET /indicate/indicators/1.json
  def show
  end

  # GET /indicate/indicators/indicator_file
  def new
    @indicate_indicator = Indicate::Indicator.new
  end

  # GET /indicate/indicators/1/edit
  def edit
  end

  # POST /indicate/indicators
  # POST /indicate/indicators.json
  def create
    @indicate_indicator = Indicate::Indicator.new(indicate_indicator_params)

    respond_to do |format|
      if @indicate_indicator.save
        format.html { redirect_to @indicate_indicator, notice: 'Indicator was successfully created.' }
        format.json { render :show, status: :created, location: @indicate_indicator }
      else
        format.html { render :new }
        format.json { render json: @indicate_indicator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /indicate/indicators/1
  # PATCH/PUT /indicate/indicators/1.json
  def update
    respond_to do |format|
      if @indicate_indicator.update
        @indicate_indicator['comment'] = params['documentation_category']['indicate_indicator']
        @indicate_indicator.save
        format.js {}
        format.json { head :no_content }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @indicate_indicator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indicate/indicators/1
  # DELETE /indicate/indicators/1.json
  def destroy
    @indicate_indicator.destroy
    respond_to do |format|
      format.html { redirect_to indicate_indicators_url, notice: 'Indicator was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_indicate_indicator
      @indicate_indicator = Indicate::Indicator.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def indicate_indicator_params
      params.require(:indicate_indicator).permit(:comment)
    end
end
