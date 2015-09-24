module Repairing
  class LayersController < ApplicationController
    before_action :authenticate_user!, except: [:geo_json]
    load_and_authorize_resource

    before_action :set_repairing_layer, only: [:show, :edit, :update, :destroy, :geo_json, :create_repair_by_addr]

    def create_repair_by_addr
      @location = Geocoder.coordinates(params[:q])
      @location1 = Geocoder.coordinates(params[:q1]) unless params[:q1].empty? || params[:q] == params[:q1]

      respond_to do |format|
        if @location1
          repair = @repairing_layer.repairs.new( title: "#{params[:q]} - #{params[:q1]}", coordinates: [@location, @location1], address: params[:q], address_to: params[:q1] )
          repair.save!

          format.json { render json: Repairing::GeojsonBuilder.build_repair(repair) }
          # format.js { render :search_street }
        elsif @location
          repair = repair = @repairing_layer.repairs.new( title: params[:q], coordinates: @location, address: params[:q] )
          repair.save!

          format.json { render json: Repairing::GeojsonBuilder.build_repair(repair) }
          # format.js { render :search_house }
        else
          format.js
        end
      end
    end

    def geo_json
      result = {
          "type" => "FeatureCollection",
          "features" => @repairing_layer.to_geo_json
      }

      respond_to do |format|
        format.json { render json: result}
      end
    end

    # GET /repairing/layers
    # GET /repairing/layers.json
    def index
      @repairing_layers = Repairing::Layer.all
    end

    # GET /repairing/layers/1
    # GET /repairing/layers/1.json
    def show
    end

    # GET /repairing/layers/new
    def new
      @repairing_layer = Repairing::Layer.new
    end

    # GET /repairing/layers/1/edit
    def edit
    end

    # POST /repairing/layers
    # POST /repairing/layers.json
    def create
      @repairing_layer = Repairing::Layer.new(repairing_layer_params)

      if current_user.has_role?(:admin)
        @repairing_layer.town = Town.find(repairing_layer_params['town'])
      else
        @repairing_layer.town = Town.where(title: current_user.town).first_or_create
      end
      @repairing_layer.owner = current_user
      @repairing_layer.repairing_category = Repairing::Category.find(repairing_layer_params['repairing_category']) unless repairing_layer_params['repairing_category'].blank?

      respond_to do |format|
        if @repairing_layer.save

          repairs = read_table_from_file(@repairing_layer.repairs_file.path)

          import(@repairing_layer, repairs[:rows])

          format.html { redirect_to @repairing_layer, notice: 'Layer was successfully created.' }
          format.json { render :show, status: :created, location: @repairing_layer }
        else
          format.html { render :new }
          format.json { render json: @repairing_layer.errors, status: :unprocessable_entity }
        end
      end
    end

    def read_table_from_file path
      require 'roo'

      xls = Roo::Excelx.new(path)
      xls.default_sheet = xls.sheets.first
      read_csv_xls xls
    end

    def read_csv_xls(xls)
      cols = []
      xls.first_column.upto(xls.last_column) { |col|
        cols << xls.cell(1, col).to_s
      }

      rows = []
      2.upto(xls.last_row) do |line|
        row = {}
        xls.first_column.upto(xls.last_column ) do |col|
          row[xls.cell(1, col)] = xls.cell(line,col).to_s
        end
        rows << row
      end

      { :rows => rows, :cols => cols }
    end

    def import layer, repairs
      repairs.each do |repair|

        location = Geocoder.coordinates(repair['Адреса']) unless repair['Адреса'].blank?
        location1 = Geocoder.coordinates(repair['Адреса1']) unless repair['Адреса1'].blank?

        coordinates =
            if location1
              [location, location1]
            else
              location
            end

        layer_repair = Repairing::Repair.create(
            title: "#{repair['Адреса']}, #{repair['Робота']}",
            obj_owner: repair['Балансоутримувач'],
            subject: repair['Об\'єкт'],
            work: repair['Робота'],
            amount: repair['Вартість'],
            repair_date: repair['Дата ремонту'],
            warranty_date: repair['Гарантія'],
            description: repair['Додаткова інфориація'],

            address: repair['Адреса'],
            address_to: repair['Адреса1'],

            coordinates: coordinates
        )
        layer_repair.layer = layer
        layer_repair.save!
      end
    end

    # PATCH/PUT /repairing/layers/1
    # PATCH/PUT /repairing/layers/1.json
    def update
      respond_to do |format|
        if @repairing_layer.update(repairing_layer_params)
          format.html { redirect_to @repairing_layer, notice: 'Layer was successfully updated.' }
          format.json { render :show, status: :ok, location: @repairing_layer }
        else
          format.html { render :edit }
          format.json { render json: @repairing_layer.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /repairing/layers/1
    # DELETE /repairing/layers/1.json
    def destroy
      @repairing_layer.destroy
      respond_to do |format|
        format.html { redirect_to repairing_layers_url, notice: 'Layer was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_repairing_layer
        @repairing_layer = Repairing::Layer.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def repairing_layer_params
        params.require(:repairing_layer).permit(:title, :description, :town, :owner, :repairs_file, :repairing_category)
      end
  end
end