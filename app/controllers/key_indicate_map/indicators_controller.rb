class KeyIndicateMap::IndicatorsController < ApplicationController

  include ControllerCaching

  before_action :set_key_indicate_map_indicator, only: [:show, :edit, :update, :destroy]

  # GET /key_indicate_map/indicators
  # GET /key_indicate_map/indicators.json
  def index
    @indicator_keys = {}
    KeyIndicateMap::IndicatorKey.all.reject{|i| i.key_indicate_map_indicators.empty? }.each{|indicator|
      group = indicator['group']
      @indicator_keys[group] = {} if @indicator_keys[group].nil?
      @indicator_keys[group]['group_icon'] = indicator['group_icon']
      @indicator_keys[group]['group_color'] = indicator['group_color']
      @indicator_keys[group]['indicators'] = [] if @indicator_keys[group]['indicators'].nil?
      @indicator_keys[group]['indicators'].push({"id" => indicator.id.to_s, "name" => indicator['name']})
    }
    @indicator_keys = @indicator_keys.sort_by{|key, value| key }
    @years = KeyIndicateMap::IndicatorFile.only(:year).map{|f| f.year}
    @selected_year = params[:year].to_i if params[:year]
    if params[:key]
      @selected_key = params[:key]
      @group = KeyIndicateMap::IndicatorKey.find(@selected_key).group
    end
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

      towns.reject{|town| town.key_indicate_map_indicators.empty? }.each do |town|
        geo = TownIndicatorsGeojsonBuilder.build(town)
        result << geo unless geo.blank?
      end

      {
          "type" => "FeatureCollection",
          "features" => result
      }

    end
    respond_to do |format|
      format.json { render json: @geo_json }
    end

  end

  def get_keys
    @keys = {}

    KeyIndicateMap::IndicatorKey.all.each{|indicator|
      next if indicator.key_indicate_map_indicators.empty?
      id = indicator['id'].to_s
      @keys[id] = {} if @keys[id].nil?
      @keys[id]['name'] = indicator['name']
      @keys[id]['unit'] = indicator['unit']
      @keys[id]['integer_or_float'] = indicator['integer_or_float']
      @keys[id]['history'] = indicator['history']
    }

    respond_to do |format|
      format.json { render json: @keys }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_key_indicate_map_indicator
      @key_indicate_map_indicator = KeyIndicateMap::Indicator.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_indicate_map_indicator_params
      params[:key_indicate_map_indicator, :type, :history]
    end
end
