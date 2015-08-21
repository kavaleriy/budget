class Public::TownsController < ApplicationController
  include ControllerCaching

  layout 'application_public'

  before_action :set_town, only: [:show]

  def index
    @towns = Town.all
  end

  def show
    @budgets = Taxonomy.where(:owner => @town.title)
    @calendars = Calendar.where(:town => @town)
  end

  def geo_json
    @geo_json = use_cache do
      result = []

      towns =
          case params[:type]
            when 'areas'
              Town.areas
            else
              Town.cities + Town.towns
          end

      kyiv = ""
      # level = 1 - regions, level = 13 - region centers
      towns.reject{|town| town.documentation_documents.empty? && (town.level != 1 && town.level != 13) }.each do |town|
        if town.koatuu == "8000000000"
          kyiv = town
        else
          geo = TownGeojsonBuilder.build(town)
          result << geo unless geo.blank?
        end
      end

      if params[:type] == 'areas'
        # Kyiv would be the last in array to be over all other svg elements
        geo = TownGeojsonBuilder.build(kyiv)
        result << geo unless geo.blank?
      end

      {
          "type" => "FeatureCollection",
          "features" => result
      }

    end
    respond_to do |format|
      format.json { render json: @geo_json }
    end

  end

  private

  def set_town
    @town = Town.find(params[:town_id])
  end

end
