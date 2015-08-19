class KeyIndicateMap::IndicatorsController < ApplicationController

  include ControllerCaching

  before_action :set_key_indicate_map_indicator, only: [:show, :edit, :update, :destroy]

  # GET /key_indicate_map/indicators
  # GET /key_indicate_map/indicators.json
  def index
    @indicator_keys = KeyIndicateMap::IndicatorKey.all.reject{|i| i.key_indicate_map_indicators.empty? }.group_by{|i| i.group }
    @years = KeyIndicateMap::Indicator.all.group_by{|i| i.key_indicate_map_indicator_file.year }.keys
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

  def geo_json
    @geo_json = use_cache do
      result = []

      towns =
          case params[:type]
            when 'areas'
              Town.areas
            else
              Town.cities + Town.towns
          end

      kyiv = ""
      towns.reject{|town| town.key_indicate_map_indicators.empty? }.each do |town|
        if town.koatuu == "8000000000"
          kyiv = town
        end
        geo = TownIndicatorsGeojsonBuilder.build(town)
        result << geo unless geo.blank?
      end

      # Kyiv would be the last in array to be over all other svg elements
      geo = TownIndicatorsGeojsonBuilder.build(kyiv)
      result << geo unless geo.blank?

      {
          "type" => "FeatureCollection",
          "features" => result
      }

    end
    respond_to do |format|
      format.json { render json: @geo_json }
    end

  end

  def forUkraine
    data = KeyIndicateMap::IndicatorKey.all.reject{|i| i.key_indicate_map_indicators.empty? }
    respond_to do |format|
      format.json { render json: data }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_key_indicate_map_indicator
      @key_indicate_map_indicator = KeyIndicateMap::Indicator.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_indicate_map_indicator_params
      params[:key_indicate_map_indicator, :type]
    end
end
