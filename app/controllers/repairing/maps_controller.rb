class Repairing::MapsController < ApplicationController

  def show
  end

  def geo_json
    @geoJsons = []
    Repairing::Layer.each { |layer| @geoJsons << layer.to_geo_json }

    result = {
        "type" => "FeatureCollection",
        "features" => @geoJsons.flatten
    }

    respond_to do |format|
      format.json { render json: result }
    end
  end

end
