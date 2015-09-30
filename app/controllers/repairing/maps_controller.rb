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
        @geoJsons[category] = {} if @geoJsons[category].nil?

        layer.repairs.each{|repair|
          if repair.repairing_category.nil?
            sub = "no_category"
          else
            sub = repair.repairing_category.id.to_s
          end

          @geoJsons[category][sub] = {
              "type" => "FeatureCollection",
              "features" => []
          } if @geoJsons[category][sub].nil?

          @geoJsons[category][sub]["features"] << Repairing::GeojsonBuilder.build_repair(repair)
        }
      }

      # result = {}
      #
      # @geoJsons.each{|key, category|
      #   result[key] = {
      #       "type" => "FeatureCollection",
      #       "features" => category.flatten
      #   }
      # }

      result = @geoJsons

      respond_to do |format|
        format.json { render json: result }
      end
    end

  end
end