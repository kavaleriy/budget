module Repairing
  class MapsController < ApplicationController
    layout 'visify', only: [:frame]
    after_filter :allow_iframe, only: [:frame]
    before_filter :set_map_params, only: [:show, :frame]

    def set_map_params
      @categories = get_categories

      @zoom = params[:zoom]

      @map_center = [48.5, 31.2] # center of Ukraine

      if params[:town_id] && params[:town_id] != '0'
        @town = params[:town_id]
        town = Town.find(@town)

        # Add this 'if' for 'Demonstration of a typical city profile' because this town has not coordinates
        if !town['coordinates'].nil?
          if town.level && town.level.eql?(1)  # area
            regional_center = Town.where(area_title: town.title, level: 13).first  # level: 13 - regional_center(town) of area
            @map_center = regional_center['coordinates'] unless regional_center.nil?
          elsif town.level  # town or region
            @map_center = town['coordinates']
          end
        else
          @zoom = '6' # view map Ukraine
        end

      else
        @town = ""
      end

      @year = params[:year] || ''
    end

    def show
      @current_user_town = Town.get_user_town(current_user)
      respond_to do |format|
        format.html
        format.js
      end
    end

    # TODO: delete this method, his views and use method frame for show layers by town in town profile
    # WARN: script in _frame.html.haml don`t use geo_json method
    def show_town
      @current_user_town = Town.get_user_town(current_user)
      respond_to do |format|
        format.html
        format.js
      end
    end

    def frame
      @partners = Modules::Partner.by_category(t('maps.show.map')).get_publish_partners.order(order_logo: :asc)
      respond_to do |format|
        format.html
        format.js
      end
    end

    def geo_json
      start_time = Time.now
      repairings = Repairing::Layer.valid_layers_with_repairs
      geo_jsons = []
      # if params[:town] not empty filter array by town
      repairings.select!{ |key,value| key['town_id'].to_s.eql?(params[:town]) } unless params[:town].blank?
      repairings.each { |layer,repairs|
        repairs.each do |repair|
          repair['layer'] = {}
          repair['layer']['town_id'] = layer['town_id'].to_s
          repair['layer']['repairing_category_id'] = layer['repairing_category_id'].to_s

          repair_json = Repairing::GeojsonBuilder.build_repair(repair)
          geo_jsons << repair_json if repair_json
        end

      }
      result = {
                "type" => "FeatureCollection",
                "features" => geo_jsons
               }
      puts Time.now - start_time
      respond_to do |format|
        format.json { render json: result }
      end
    end

    def instruction

    end

    def download

      file_path = Rails.public_path.to_s + '/files/file_examples/repair_layer.xlsx'
      if File.exist?(file_path)
        send_file(
            "#{file_path}",
            :x_sendfile=>true
        )
      else
        redirect_to :back, notice: t('budget_files_controller.not_download_file')
      end
    end

    def getInfoContentForPopup
      # this function have url 'repairing/map/getInfoContentForPopup/:repair_id'
      # format: *.js
      # get params[:repair_id]
      # find Repair object by params[:repair_id]
      # render partial for popup container
      @repair = Repairing::Repair.find(params[:repair_id])
      render partial: 'info_popup'
    end

    def get_heapmap_geo_json
      repairings = Repairing::Repair.where(:coordinates.ne => nil ).entries
      geo_json = []
      repairings.each do |repair|
        geo_json << {
            type: "Feature",
            geometry: {
                type: 'Point',
                coordinates: repair[:coordinates]
            },
            properties: {
                id: repair[:id],
                repair: "house",
                amount: repair[:amount]
            }
        } unless repair[:coordinates].nil? || repair[:coordinates][0].nil? || repair[:coordinates][1].nil?

      end
      result = {
          "type" => "FeatureCollection",
          "features" => geo_json
      }

      respond_to do |format|
        format.json { render json: result }
      end
    end

    def heapmap

    end

    private

    def allow_iframe
      response.headers['x-frame-options'] = 'ALLOWALL'
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    end

    def get_categories
      categories = {}
      Repairing::Category.all.reject{|p| p.category.nil? }.each{|category|
        categories[category.category.id.to_s] = [] if categories[category.category.id.to_s].nil?
        categories[category.category.id.to_s] << category
      }
      categories
    end

  end
end