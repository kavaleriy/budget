module Repairing
  class MapsController < ApplicationController
    layout 'visify', only: [:frame]
    after_filter :allow_iframe, only: [:frame]

    def show
      @categories = get_categories
    end

    def frame
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