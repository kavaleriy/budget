module Properting
  class PropertiesController < ApplicationController
    layout 'application_admin'
    layout 'application', only: [:cross_busroute_with_propertings]
    before_action :update_properting_coordinates, only: [:update]

    before_action :set_properting_property, only: %i[show
                                                     edit
                                                     update
                                                     destroy
                                                     show_property_info
                                                     edit_in_modal
                                                     photos
                                                     photos_slider
                                                     property_on_map]

    def index
      @properting_properties = Properting::Property.all
    end

    def show
      respond_to do |format|
        format.json { render json: Properting::GeojsonBuilder.build_property(@properting_property) }
      end
    end

    def new
      @properting_property = Properting::Property.new
    end

    def edit
      respond_to do |format|
        format.js { render :edit }
      end
    end

    def create
      layer = Properting::Layer.find(params[:layer_id])

      @properting_property = layer.properties.new(properting_property_params)

      respond_to do |format|
        if @properting_property.save
          format.json { render :show, status: :created, location: @properting_map_property }
        else
          format.html { render :new }
          format.json { render json: @properting_property.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        properting_property_params.delete :properting_category if properting_property_params[:properting_category].blank?
        if @properting_property.update(properting_property_params)
          flash[:notice] = I18n.t('repairing.layers.update.success')
          msg = { class_name: 'success', message: flash[:notice] }
          format.js {}
          format.json { render :show, status: :ok, json: msg }
        else
          flash[:notice] = @properting_property.errors
          format.js {}
          format.json { render json: @properting_property.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @properting_property.destroy

      respond_to do |format|
        format.html { redirect_to properting_layer_path(@properting_property.layer_id) }
        format.json { head :no_content }
        format.js   { render layout: false }
      end
    end

    def show_property_info
      if @properting_property.obj_owner.blank?
        prozzoro_info = ExternalApi.prozzoro_data(@properting_property.prozzoro_id)
        unless prozzoro_info.nil?
          @properting_property.obj_owner = prozzoro_info['awards'].first['suppliers'].first['name'] if prozzoro_info['awards'].present?
        end
      end
    end

    def edit_in_modal
      @properting_property.valid?
    end

    def photos
      @photo = Properting::Photo.new
      respond_to do |format|
        format.html { render layout: 'application_admin' }
      end
    end

    def photos_slider; end

    def property_on_map; end

    private

    def set_properting_property
      @properting_property = Properting::Property.find(params[:id])
    end

    def update_properting_coordinates
      par = params[:properting_property][:coordinates]
      unless par.nil?
        if par.is_a?(Array)
          coordinates = par.map(&:to_f)
          params[:properting_property][:coordinates] = coordinates
        else
          coordinates = par.split(') ').map { |p| p.split(', ') }.map { |p| [p[0].split('LatLng(')[1].to_f, p[1].to_f] }
          params[:properting_property][:coordinates] = coordinates
        end
      end
    end

    def properting_property_params
      params.require(:properting_property).permit!
    end
  end
end
