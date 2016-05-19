module Repairing
  class LayersController < ApplicationController
    layout 'application_admin'

    before_action :authenticate_user!, except: [:geo_json]
    load_and_authorize_resource

    before_action :set_repairing_layer, only: [:show, :edit, :update, :destroy, :geo_json, :create_repair_by_addr]

    def create_repair_by_addr
      @location = Geocoder.coordinates(params[:q])
      @location1 = Geocoder.coordinates(params[:q1]) unless params[:q1].empty? || params[:q] == params[:q1]

      respond_to do |format|
        if @location1
          repair = @repairing_layer.repairs.new( subject: "#{params[:q]} - #{params[:q1]}", coordinates: [@location, @location1], address: params[:q], address_to: params[:q1] )
          repair.save!

          format.json { render json: Repairing::GeojsonBuilder.build_repair(repair) }
          # format.js { render :search_street }
        elsif @location
          repair = repair = @repairing_layer.repairs.new( subject: params[:q], coordinates: @location, address: params[:q] )
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
      @repairing_layers = Repairing::Layer.visible_to(current_user).page(params[:page]).per(10)
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

          unless @repairing_layer.repairs_file.path.nil?
            repairs = read_table_from_file(@repairing_layer.repairs_file.path)
            import(@repairing_layer, repairs[:rows])

            Thread.new do
              @repairing_layer.repairs.each do |repair|
                repair.coordinates = RepairingGeocoder.calc_coordinates(repair.address, repair.address_to)
                repair.save!
              end
            end
          end

          format.html { redirect_to @repairing_layer, notice: "Ремонтні роботи успішно завантажено. Завершення обчислення координат очікується через #{@repairing_layer.repairs.count / 2} сек." }
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

        coordinates = nil # calc in background

        repair_hash = build_repair_hash(repair, coordinates)

        layer_repair = Repairing::Repair.create(repair_hash)
        layer_repair.layer = layer
        category = Repairing::Category.where(:title => repair['Робота']).first
        layer_repair.repairing_category = category unless category.nil?
        layer_repair.save!
      end
    end

    # PATCH/PUT /repairing/layers/1
    # PATCH/PUT /repairing/layers/1.json
    def update
      respond_to do |format|
        if @repairing_layer.update(repairing_layer_params)
          format.js
          format.json { head :no_content }
        else
          format.js
          format.json { head :no_content }
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

    def get_categories
      categories = Repairing::Category.all.select{|c| c.category.nil?}.map{|c| {id: c.id.to_s, text: c.title}}

      respond_to do |format|
        format.json { render json: categories}
      end
    end

    private
      def build_repair_hash(repair, coordinates)
        # this function build hash for repair model
        # get two parameters repair hash and coordinates array
        # first of all convert repair start and end date to date
        # after that build and return hash
        start_repair_date = repair['Дата початку ремонту'].to_date  unless repair['Дата початку ремонту'].nil?
        end_repair_date = repair['Дата закінчення ремонту'].to_date  unless repair['Дата закінчення ремонту'].nil?
        {
            obj_owner: repair['Виконавець'],
            subject: repair['Об\'єкт'],
            work: repair['Робота'],
            amount: repair['Вартість'],
            warranty_date: repair['Гарантія'],
            description: repair['Додаткова інформація'],

            repair_start_date: start_repair_date,
            repair_end_date: end_repair_date,
            edrpou_artist: repair['ЄДРПОУ виконавця'],
            spending_units: repair['Розпорядник бюджетних коштів'],
            edrpou_spending_units: repair['ЄДРПОУ Розпорядника бюджетних коштів'],

            address: repair['Адреса'],
            address_to: repair['Адреса1'],

            coordinates: coordinates
        }
      end
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