class KeyIndicateMap::IndicatorKeysController < ApplicationController

  helper_method :sort_column, :sort_direction

  before_action :set_key_indicate_map_indicator_key, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /key_indicate_map/indicator_keys
  # GET /key_indicate_map/indicator_keys.json
  def index
    @key_indicate_map_indicator_keys = KeyIndicateMap::IndicatorKey.order(sort_column + " " + sort_direction)
  end

  # GET /key_indicate_map/indicator_keys/1
  # GET /key_indicate_map/indicator_keys/1.json
  def show
  end

  # GET /key_indicate_map/indicator_keys/new
  def new
    @key_indicate_map_indicator_key = KeyIndicateMap::IndicatorKey.new
  end

  # GET /key_indicate_map/indicator_keys/1/edit
  def edit
  end

  # POST /key_indicate_map/indicator_keys
  # POST /key_indicate_map/indicator_keys.json
  def create
    @key_indicate_map_indicator_key = KeyIndicateMap::IndicatorKey.new(key_indicate_map_indicator_key_params)

    respond_to do |format|
      if @key_indicate_map_indicator_key.save
        format.html { redirect_to @key_indicate_map_indicator_key, notice: 'Indicator key was successfully created.' }
        format.json { render :show, status: :created, location: @key_indicate_map_indicator_key }
      else
        format.html { render :new }
        format.json { render json: @key_indicate_map_indicator_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /key_indicate_map/indicator_keys/1
  # PATCH/PUT /key_indicate_map/indicator_keys/1.json
  def update
    respond_to do |format|
      if @key_indicate_map_indicator_key.update(key_indicate_map_indicator_key_params)
        format.html { redirect_to @key_indicate_map_indicator_key, notice: 'Indicator key was successfully updated.' }
        format.json { render :show, status: :ok, location: @key_indicate_map_indicator_key }
      else
        format.html { render :edit }
        format.json { render json: @key_indicate_map_indicator_key.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /key_indicate_map/indicator_keys/1
  # DELETE /key_indicate_map/indicator_keys/1.json
  def destroy
    @key_indicate_map_indicator_key.destroy
    respond_to do |format|
      format.html { redirect_to key_indicate_map_indicator_keys_url, notice: 'Indicator key was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def sort_column
      KeyIndicateMap::IndicatorKey.fields.keys.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_key_indicate_map_indicator_key
      @key_indicate_map_indicator_key = KeyIndicateMap::IndicatorKey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_indicate_map_indicator_key_params
      params[:key_indicate_map_indicator_key]
    end
end
