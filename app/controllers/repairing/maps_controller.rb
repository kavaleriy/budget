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
        @map_center = town['coordinates'] if town.level && town.level > 1 # area
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

    def frame
    end

    def geo_json
      repairings = Repairing::Repair.valid_repairs
      binding.pry
      geo_jsons = []
      # if params[:town] not empty filter array by town
      repairings.select!{|rep| rep['layer']['town_id'].to_s.eql?(params[:town]) } unless params[:town].blank?
      repairings.each { |repair|
        unless repair['layer_id'].nil?
          repair_json = Repairing::GeojsonBuilder.build_repair(repair)
          geo_jsons << repair_json if repair_json
        end
      }
      result = {
                "type" => "FeatureCollection",
                "features" => geo_jsons
               }
      respond_to do |format|
        format.json { render json: result }
      end
    end

    def instruction

    end

    def download
      file_path = Rails.public_path.to_s + '/files/files_for_instructions/repairing_map.xlsx'
      if File.exist?(file_path)
        send_file(
            "#{file_path}",
            :x_sendfile=>true
        )
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