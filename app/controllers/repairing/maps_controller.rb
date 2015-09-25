module Repairing
  class MapsController < ApplicationController

    def show
      @categories = {}
      Repairing::Category.all.reject{|p| p.category.nil? }.each{|category|
        @categories[category.category.id.to_s] = [] if @categories[category.category.id.to_s].nil?
        @categories[category.category.id.to_s] << category
      }
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