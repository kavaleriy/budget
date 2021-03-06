
module Repairing
  class LayersController < ApplicationController
    layout 'application_admin'
    helper_method :sort_column, :sort_direction

    before_action :authenticate_user!, except: [:geo_json]
    before_action :set_categories, only: [:index, :new, :edit]
    load_and_authorize_resource

    before_action :set_repairing_layer, only: [:show, :edit, :update, :destroy, :geo_json, :create_repair_by_addr, :subcategories, :update_repairs_category, :subcategories_select]
    before_action :set_repairs, only: [:show, :edit]

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
      @repairing_layers = Repairing::Layer.by_locale.visible_to(current_user)

      @repairing_layers = @repairing_layers.by_towns(params['town_select'])   unless params['town_select'].blank?
      @repairing_layers = @repairing_layers.find_by_string(params['q'])       unless params['q'].blank?
      @repairing_layers = @repairing_layers.by_category(params['category'])   unless params['category'].blank?
      @repairing_layers = @repairing_layers.by_status(params['status'])       unless params['status'].blank?
      @repairing_layers = @repairing_layers.by_year(params['year'])           unless params['year'].blank?

      @repairing_layers = @repairing_layers.order(sort_column + ' ' + sort_direction)

      @repairing_layers = @repairing_layers.page(params[:page])

      respond_to do |format|
        format.js
        format.html
      end
    end

    # GET /repairing/layers/1
    # GET /repairing/layers/1.json
    def show
      respond_to do |format|
        format.js
        format.html
      end
    end

    # GET /repairing/layers/new
    def new
      @repairing_layer = Repairing::Layer.new
    end

    # GET /repairing/layers/1/edit
    def edit
      respond_to do |format|
        format.html
        format.js { render action: 'show' }
      end
    end

    # POST /repairing/layers
    # POST /repairing/layers.json
    def create
      @repairing_layer = Repairing::Layer.new(repairing_layer_params)
      @repairing_layer.owner = current_user
      # @repairing_layer.repairing_category = Repairing::Category.find(repairing_layer_params['repairing_category']) unless repairing_layer_params['repairing_category'].blank?

      respond_to do |format|
        if @repairing_layer.save
          unless @repairing_layer.repairs_file.path.nil?
            # repairs = read_table_from_file(@repairing_layer.repairs_file.path)
            Repairing::Repair.import(@repairing_layer, @repairing_layer.repairs_file.path,params[:child_category])

            Thread.new do
              @repairing_layer.repairs.each do |repair|
                repair.coordinates = RepairingGeocoder.calc_coordinates(repair.address, repair.address_to) if repair.coordinates.blank?
                repair.save(validate: false)
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
          update_subcategory if repairing_layer_params[:repairing_category].present?

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

    # DELETE /repairing/layers/1
    # DELETE /repairing/layers/1.json
    def destroy
      @repairing_layer.destroy
      respond_to do |format|
        format.html { redirect_to repairing_layers_url, notice: 'Layer was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def multiple_destroy
      Repairing::Layer.get_by_ids(params[:ids]).destroy_all
      redirect_to :back
    end

    def categories
      categories = Repairing::Category.by_locale.select{|c| c.category.nil?}.map{|c| {id: c.id.to_s, text: c.title}}

      respond_to do |format|
        format.json { render json: categories }
      end
    end

    def subcategories
      subcategories = Repairing::Category.where(category: @repairing_layer.repairing_category_id).map{|c| {id: c.id.to_s, text: c.title}}

      respond_to do |format|
        format.json { render json: subcategories }
      end
    end

    def update_subcategory(category = '')
      @repairing_layer.repairs.update_all(repairing_category_id: category)
    end

    def update_repairs_category
      update_subcategory(params[:update_repairs_category][:repairing_subcategory])
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
      if ( coordinates =~ /^\d{1,2}[.]\d*/ )
        Geocoder.coordinates(coordinates)
      else
        user_town = current_user.town_model.title
        Geocoder.coordinates(user_town + ' ' + coordinates)
      end
    end

    def sort_column
      Repairing::Layer.fields.keys.include?(params[:sort]) ? params[:sort] : "title"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_repairing_layer
      @repairing_layer = Repairing::Layer.find(params[:id])
    end

    def set_repairs
      @repairs = Repairing::Repair.by_layer(params[:layer_id]).page(params[:page]).per(100) unless params[:layer_id].blank?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repairing_layer_params
      params.require(:repairing_layer).permit(:title, :description, :town, :owner, :repairs_file, :repairing_category, :locale, :status, :year)
    end

    def set_categories
      @categories = Repairing::Category.by_locale.select{|p| p.category.nil?}
    end
  end
end
