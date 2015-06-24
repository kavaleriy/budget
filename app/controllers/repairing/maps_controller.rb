class Repairing::MapsController < ApplicationController

  def show
  end

  def geo_json
    @geoJsons = []
    Repairing::Layer.each { |layer| @geoJsons << layer.to_geo_json }

    respond_to do |format|
      format.json { render json: @geoJsons.flatten}
    end
  end

end
