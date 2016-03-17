module Repairing
  class MapsController < ApplicationController
    layout 'visify', only: [:frame]
    after_filter :allow_iframe, only: [:frame]
    before_filter :set_map_params, only: [:show, :frame]
    def set_map_params
      @categories = get_categories

      @zoom = params[:zoom]

      if params[:town_id]
        @town = params[:town_id]
        @map_center = Town.find(@town)['coordinates']
      else
        @town = ""
        @map_center = [48.5, 31.2] # center of Ukraine
      end
    end

    def show
    end

    def frame
    end

    def geo_json
      @geoJsons = []
      Repairing::Repair.each { |repair|
        repair = Repairing::GeojsonBuilder.build_repair(repair)
        @geoJsons << repair if repair
      }

      result = {
                "type" => "FeatureCollection",
                "features" => @geoJsons
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