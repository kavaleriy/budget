module Repairing
  class RepairsController < ApplicationController
    layout 'application_admin'

    before_filter :update_repairing_coordinates, only: [:update]

    before_action :set_repairing_repair, only: [:show, :edit, :update, :destroy,:show_repair_info, :e_data, :prozzoro_info]

    # GET /repairing/repairs
    # GET /repairing/repairs.json
    def index
      @repairing_repairs = Repairing::Repair.all
    end

    # GET /repairing/repairs/1
    # GET /repairing/repairs/1.json
    def show
      respond_to do |format|
        format.json { render json: Repairing::GeojsonBuilder.build_repair(@repairing_repair) }
      end
    end

    # GET /repairing/repairs/new
    def new
      @repairing_repair = Repairing::Repair.new
    end

    # GET /repairing/repairs/1/edit
    def edit

      respond_to do |format|
        format.js { render :edit }
      end
    end

    # POST /repairing/repairs
    # POST /repairing/repairs.json
    def create
      layer = Repairing::Layer.find(params[:layer_id])

      @repairing_repair = layer.repairs.new(repairing_repair_params)

      respond_to do |format|
        if @repairing_repair.save
          format.json { render :show, status: :created, location: @repairing_map_repair }
        else
          format.html { render :new }
          format.json { render json: @repairing_repair.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /repairing/repairs/1
    # PATCH/PUT /repairing/repairs/1.json
    def update
      respond_to do |format|
        if @repairing_repair.update(repairing_repair_params)
          flash[:notice] = I18n.t('repairing.layers.update.success')
          format.js {}
          format.json { render :show, status: :ok }
        else
          format.json { render json: @repairing_repair.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /repairing/repairs/1
    # DELETE /repairing/repairs/1.json
    def destroy
      @repairing_repair.destroy
      respond_to do |format|
        format.js
      end
    end

    def show_repair_info
      render 'show_repair_info',layout: false
    end

    def e_data
      require 'external_api'
      # payer_edrpous = '37836770'
      # recipt_edrpous = '37755173'
      e_data_payments = ExternalApi.e_data_payments(@repairing_repair.edrpou_artist, @repairing_repair.edrpou_spending_units) || []
      # e_data_payments = ExternalApi.e_data_payments(payer_edrpous, recipt_edrpous)

      @payments = Kaminari.paginate_array(e_data_payments).page(params[:page]).per(10)

      respond_to do |format|
        format.html {render partial: 'modules/classifier/search_e_data',layout: false}
        format.js {
          render file: 'repairing/repairs/api_info',
                 locals: {
                     partial_name: 'modules/classifier/search_e_data'
                 }
        }
      end

    end

    def prozzoro_info
      require 'external_api'
      @prozzoro_info = ExternalApi.prozzoro_data(@repairing_repair.prozzoro_id)
      respond_to do |format|
        format.js {
          render file: 'repairing/repairs/api_info',
                 locals: {
                     partial_name: 'repairing/repairs/prozzoro_info'
                 }
        }
      end
    end
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_repairing_repair
        @repairing_repair = Repairing::Repair.find(params[:id])
      end

      def update_repairing_coordinates
        par = params[:repairing_repair][:coordinates]
        unless (par.nil? || par.kind_of?(Array))
          coordinates = par.split(") ").map{|p| p.split(", ")}.map{|p| [p[0].split("LatLng(")[1],p[1]]}
          params[:repairing_repair][:coordinates] = coordinates
        end
      end

    # Never trust parameters from the scary internet, only allow the white list through.
      def repairing_repair_params
        params.require(:repairing_repair).permit! #(:description, :amount, :repair_date, :address, :address_to, :coordinates).tap { |whitelisted|  whitelisted[:coordinates] = params[:repairing_repair][:coordinates] }
      end
  end
end