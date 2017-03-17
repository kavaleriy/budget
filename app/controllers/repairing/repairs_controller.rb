module Repairing
  class RepairsController < ApplicationController
    layout 'application_admin'
    # before_action :check_admin_permission, except: [:cross_busroute_with_repairings]
    layout 'application' , only: [:cross_busroute_with_repairings]
    before_filter :update_repairing_coordinates, only: [:update]

    before_action :set_repairing_repair, only: [:show, :edit, :update, :destroy, :show_repair_info]

    # GET  /repairing/repairs
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
          flash[:notice] = I18n.t('repairing.layers.update.success')  # edit repair message for form
          msg = {class_name: 'success', message: flash[:notice]}      # edit repair message for x-editable
          format.js {}
          format.json{ render :show, status: :ok, json: msg }
        else
          # localization messages for error fields in uk.locale.yml(attributes:)
          flash[:notice] = @repairing_repair.errors
          format.js {}
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
      if @repairing_repair.obj_owner.blank?
        prozzoro_info = ExternalApi.prozzoro_data(@repairing_repair.prozzoro_id)
        unless prozzoro_info.nil?
          @repairing_repair.obj_owner = prozzoro_info['awards'].first['suppliers'].first['name'] unless prozzoro_info['awards'].blank?
        end
      end

    end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_repairing_repair
        @repairing_repair = Repairing::Repair.find(params[:id])
      end

      def update_repairing_coordinates
        par = params[:repairing_repair][:coordinates]
        unless par.nil?
          if par.kind_of?(Array)
            coordinates = par.map{|p| p.to_f}
            params[:repairing_repair][:coordinates] = coordinates
          else
            coordinates = par.split(") ").map{|p| p.split(", ")}.map{|p| [p[0].split("LatLng(")[1].to_f,p[1].to_f]}
            params[:repairing_repair][:coordinates] = coordinates
          end
        end
      end

    # Never trust parameters from the scary internet, only allow the white list through.
      def repairing_repair_params
        params.require(:repairing_repair).permit! #(:description, :amount, :repair_date, :address, :address_to, :coordinates).tap { |whitelisted|  whitelisted[:coordinates] = params[:repairing_repair][:coordinates] }
      end
  end
end