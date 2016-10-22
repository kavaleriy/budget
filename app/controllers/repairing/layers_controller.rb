
module Repairing
  class LayersController < ApplicationController

    layout 'application_admin'

    before_action :authenticate_user!, except: [:geo_json]
    load_and_authorize_resource

    before_action :set_repairing_layer, only: [:show, :edit, :update, :destroy, :geo_json, :create_repair_by_addr]

    def create_repair_by_addr
      @location = coordinate(params[:q])
      @location1 = coordinate(params[:q1]) unless params[:q1].empty? || params[:q] == params[:q1]

      respond_to do |format|
        if @location1
          repair = @repairing_layer.repairs.new(
              subject: "#{params[:q]} - #{params[:q1]}",
              coordinates: [@location, @location1],
              address: params[:q],
              edrpou_spending_units: 00000000,
              spending_units: 'Unknown',
              amount: 1.00,
              address_to: params[:q1]
          )
          repair.save!

          format.json { render json: Repairing::GeojsonBuilder.build_repair(repair) }
          # format.js { render :search_street }
        elsif @location
          repair = @repairing_layer.repairs.new(
              subject: params[:q],
              coordinates: @location,
              address: params[:q],
              edrpou_spending_units: 00000000,
              spending_units: 'Unknown',
              amount: 1.00,
          )
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
          type: "FeatureCollection",
          features: @repairing_layer.to_geo_json
      }

      respond_to do |format|
        format.json { render json: result}
      end
    end

    # GET /repairing/layers
    # GET /repairing/layers.json
    def index
      @repairing_layers = Repairing::Layer.by_locale.visible_to(current_user).page(params[:page])
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
            # repairs = read_table_from_file(@repairing_layer.repairs_file.path)
            Repairing::Repair.import(@repairing_layer, @repairing_layer.repairs_file.path)
            Thread.new do
              @repairing_layer.repairs.each do |repair|
                repair.coordinates = RepairingGeocoder.calc_coordinates(repair.address, repair.address_to) if repair.coordinates.blank?
                repair.save!
              end
            end
          end

          format.html { redirect_to @repairing_layer,
                        notice: t('repairing.layers.import_file_success', time: (@repairing_layer.repairs.count / 2))
                      }
          format.json { render :show, status: :created, location: @repairing_layer }
        else
          format.html { render :new }
          format.json { render json: @repairing_layer.errors, status: :unprocessable_entity }
        end

      end

    rescue Roo::Base::TypeError
      message = [t('invalid_format')]
      message << t('repairing.layers.check_xlsx_format')
      respond_with_error_message(message)
    rescue DBF::Column::NameError
      message = [t('invalid_format')]
      message << t('repairing.layers.correct_formats')
      respond_with_error_message(message)
    rescue => e
      message = "#{t('repairing.layers.update.error')}"
      respond_with_error_message(message)

    end

    def respond_with_error_message(message)
      respond_to do |format|
        format.html { redirect_to :back, alert:  message }
      end
    end

    # def read_csv_xls(xls)
    #   cols = []
    #   xls.first_column.upto(xls.last_column) { |col|
    #     cols << xls.cell(1, col).to_s.strip
    #   }
    #
    #   rows = []
    #   2.upto(xls.last_row) do |line|
    #     row = {}
    #     xls.first_column.upto(xls.last_column ) do |col|
    #       row[xls.cell(1, col)] = xls.cell(line,col).to_s.strip
    #       row.transform_keys! { |key| key.strip }
    #     end
    #     rows << row
    #   end
    #
    #   { :rows => rows, :cols => cols }
    # end

    # PATCH/PUT /repairing/layers/1
    # PATCH/PUT /repairing/layers/1.json
    def update
      respond_to do |format|
        if @repairing_layer.update(repairing_layer_params)
          msg = {class_name: 'success', message: I18n.t('repairing.layers.update.success')}
          format.js
          format.json do
            render json: msg
          end
        else
          msg = {class_name: 'danger' ,message: I18n.t('repairing.layers.update.error')}
          format.js
          format.json do
            render json: msg
          end
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
      categories = Repairing::Category.by_locale.select{|c| c.category.nil?}.map{|c| {id: c.id.to_s, text: c.title}}

      respond_to do |format|
        format.json { render json: categories}
      end
    end

    private
      def coordinate(coordinates)
        if ( coordinates =~ /^\d{1,2}[.]\d*/ )
          Geocoder.coordinates(coordinates)
        else
          user_town = current_user.town
          Geocoder.coordinates(user_town + ' ' + coordinates)
        end
      end


      # Use callbacks to share common setup or constraints between actions.
      def set_repairing_layer
        @repairing_layer = Repairing::Layer.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def repairing_layer_params
        params.require(:repairing_layer).permit(:title, :description, :town, :owner, :repairs_file, :repairing_category, :locale)
      end
  end
end