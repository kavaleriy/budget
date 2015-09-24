module Repairing
  class MapsController < ApplicationController

    def show
    end

    def geo_json
      @geoJsons = {}
      Repairing::Layer.each { |layer|
        if layer.repairing_category.nil?
          category = "no_category"
        else
          category = layer.repairing_category.id.to_s
        end
        @geoJsons[category] = [] if @geoJsons[category].nil?
        @geoJsons[category] << layer.to_geo_json
      }

      result = {}

      @geoJsons.each{|key, category|
        result[key] = {
            "type" => "FeatureCollection",
            "features" => category.flatten
        }
      }

      respond_to do |format|
        format.json { render json: result }
      end
    end

  end
end