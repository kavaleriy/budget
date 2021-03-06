module Properting
  class LayersController < ApplicationController
    layout 'application_admin'
    include PropertingLayerUpload
    helper_method :sort_column, :sort_direction

    before_action :authenticate_user!, except: [:geo_json]
    before_action :set_categories, only: %i[index new edit]
    load_and_authorize_resource

    before_action :set_properting_layer, only: %i[show
                                                  edit
                                                  update
                                                  destroy
                                                  geo_json
                                                  create_property_by_addr
                                                  subcategories
                                                  update_properties_category
                                                  subcategories_select]
    before_action :set_properties, only: %i[show edit]

    def create_property_by_addr
      @location = coordinate(params[:q])
      @location1 = coordinate(params[:q1]) unless params[:q1].empty? || params[:q] == params[:q1]

      respond_to do |format|
        if @location1
          property = @properting_layer.properties.new(
            subject: "#{params[:q]} - #{params[:q1]}",
            coordinates: [@location, @location1],
            address: params[:q],
            edrpou_balance_holder: 000000000,
            obj_owner: 'Unknown',
            amount: 1.00,
            address_to: params[:q1]
          )
          property.save!

          format.json { render json: Properting::GeojsonBuilder.build_property(property) }
          # format.js { render :search_street }
        elsif @location
          property = @properting_layer.properties.new(
            subject: params[:q],
            coordinates: @location,
            address: params[:q],
            edrpou_balance_holder: 000000000,
            obj_owner: 'Unknown',
            amount: 1.00
          )
          property.save!

          format.json { render json: Properting::GeojsonBuilder.build_property(property) }
          # format.js { render :search_house }
        else
          format.js
        end
      end
    end

    def geo_json
      # binding.pry
      result = {
        type: 'FeatureCollection',
        features: @properting_layer.to_geo_json
      }

      respond_to do |format|
        format.json { render json: result }
      end
    end

    def index
      @properting_layers = Properting::Layer.by_locale.visible_to(current_user)

      @properting_layers = @properting_layers.by_towns(params['town_select'])   if params['town_select'].present?
      @properting_layers = @properting_layers.find_by(string: params['q'])      if params['q'].present?
      @properting_layers = @properting_layers.by_category(params['category'])   if params['category'].present?
      @properting_layers = @properting_layers.by_status(params['status'])       if params['status'].present?
      @properting_layers = @properting_layers.by_year(params['year'])           if params['year'].present?

      @properting_layers = @properting_layers.order(sort_column + ' ' + sort_direction)

      @properting_layers = @properting_layers.page(params[:page])

      respond_to do |format|
        format.js
        format.html
      end
    end

    def show
      respond_to do |format|
        format.js
        format.html
      end
    end

    def new
      @properting_layer = Properting::Layer.new
    end

    def edit
      respond_to do |format|
        format.html
        format.js { render action: 'show' }
      end
    end

    def create
      path_file =  open_file(properting_layer_params[:properties_file])

      respond_to do |format|
        unless path_file.nil?
          Properting::Property.import(path_file, params[:child_category], current_user, properting_layer_params)

          # Thread.new do
          #   @properting_layer.properties.each do |property|
          #     property.coordinates = RepairingGeocoder.calc_coordinates(property.address, property.address_to) if property.coordinates.blank?
          #     property.save(validate: false)
          #   end
          # end
        end
        format.html {
          redirect_to properting_layer_path(properting_layer_params[:town]), notice: 'Дані завантажено'
        }
      end
    rescue Roo::Base::TypeError
      message = [t('invalid_format')]
      message << t('repairing.layers.check_xlsx_format')
      respond_with_error_message(message)
    rescue DBF::Column::NameError
      message = [t('invalid_format')]
      message << t('repairing.layers.correct_formats')
      respond_with_error_message(message)
    rescue StandardError => e
      message = t('repairing.layers.update.error').to_s
      respond_with_error_message(message)
    end

    def respond_with_error_message(message)
      respond_to do |format|
        format.html { redirect_to :back, alert: message }
      end
    end

    def update
      respond_to do |format|
        if @properting_layer.update(properting_layer_params)
          update_subcategory if properting_layer_params[:properting_category].present?

          msg = { class_name: 'success', message: I18n.t('repairing.layers.update.success') }
          format.js
          format.json { render json: msg }
        else
          msg = { class_name: 'danger', message: I18n.t('repairing.layers.update.error') }
          format.js
          format.json { render json: msg }
        end
      end
    end

    def destroy
      @properting_layer.destroy
      respond_to do |format|
        format.html { redirect_to properting_layers_url, notice: 'Layer was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def multiple_destroy
      Properting::Layer.get_by_ids(params[:ids]).destroy_all
      redirect_to :back
    end

    def categories
      categories = Properting::Category.by_locale.select { |c| c.category.nil? }.map { |c| { id: c.id.to_s, text: c.title } }

      respond_to do |format|
        format.json { render json: categories }
      end
    end

    def subcategories
      subcategories = Properting::Category.where(category: @properting_layer.properting_category_id).map { |c| { id: c.id.to_s, text: c.title } }

      respond_to do |format|
        format.json { render json: subcategories }
      end
    end

    def update_subcategory(category='')
      @properting_layer.properties.update_all(properting_category_id: category)
    end

    def update_properties_category
      update_subcategory(params[:update_properties_category][:properting_subcategory])
      msg = { class_name: 'success', message: I18n.t('repairing.layers.update.success') }

      respond_to do |format|
        format.json { render json: msg }
      end
    end

    def subcategories_select
      respond_to do |format|
        format.js
      end
    end

    private

    def coordinate(coordinates)
      if coordinates =~ /^\d{1,2}[.]\d*/
        Geocoder.coordinates(coordinates)
      else
        user_town = current_user.town_model.title
        Geocoder.coordinates(user_town + ' ' + coordinates)
      end
    end

    def sort_column
      Properting::Layer.fields.key?(params[:sort]) ? params[:sort] : 'title'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_properting_layer
      @properting_layer = Properting::Layer.find(params[:id])
    end

    def set_properties
      @properties = Properting::Property.by_layer(params[:layer_id]).page(params[:page]).per(100) if params[:layer_id].present?
    end

    def properting_layer_params
      params.require(:properting_layer).permit(:title,
                                               :description,
                                               :town,
                                               :owner,
                                               :properties_file,
                                               :properting_category,
                                               :locale,
                                               # :status,
                                               :year)
    end

    def set_categories
      @categories = Properting::Category.by_locale.select { |p| p.category.nil? }
    end
  end
end
