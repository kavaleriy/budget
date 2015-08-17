class KeyIndicateMap::IndicatorsController < ApplicationController
  before_action :set_key_indicate_map_indicator, only: [:show, :edit, :update, :destroy]

  # GET /key_indicate_map/indicators
  # GET /key_indicate_map/indicators.json
  def index
    @key_indicate_map_indicators = KeyIndicateMap::Indicator.all
  end

  # GET /key_indicate_map/indicators/1
  # GET /key_indicate_map/indicators/1.json
  def show
  end

  # GET /key_indicate_map/indicators/new
  def new
    @key_indicate_map_indicator = KeyIndicateMap::Indicator.new
  end

  # GET /key_indicate_map/indicators/1/edit
  def edit
  end

  # POST /key_indicate_map/indicators
  # POST /key_indicate_map/indicators.json
  def create
    @key_indicate_map_indicator = KeyIndicateMap::Indicator.new(key_indicate_map_indicator_params)

    respond_to do |format|
      if @key_indicate_map_indicator.save
        format.html { redirect_to @key_indicate_map_indicator, notice: 'Indicator was successfully created.' }
        format.json { render :show, status: :created, location: @key_indicate_map_indicator }
      else
        format.html { render :new }
        format.json { render json: @key_indicate_map_indicator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /key_indicate_map/indicators/1
  # PATCH/PUT /key_indicate_map/indicators/1.json
  def update
    respond_to do |format|
      if @key_indicate_map_indicator.update(key_indicate_map_indicator_params)
        format.html { redirect_to @key_indicate_map_indicator, notice: 'Indicator was successfully updated.' }
        format.json { render :show, status: :ok, location: @key_indicate_map_indicator }
      else
        format.html { render :edit }
        format.json { render json: @key_indicate_map_indicator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /key_indicate_map/indicators/1
  # DELETE /key_indicate_map/indicators/1.json
  def destroy
    @key_indicate_map_indicator.destroy
    respond_to do |format|
      format.html { redirect_to key_indicate_map_indicators_url, notice: 'Indicator was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_key_indicate_map_indicator
      @key_indicate_map_indicator = KeyIndicateMap::Indicator.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_indicate_map_indicator_params
      params[:key_indicate_map_indicator]
    end
end
