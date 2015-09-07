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
    @total_amounts = {}
    @budgets.each{|budget|
      @total_amounts[budget._type] = budget.get_total_amounts
    }
    @town_items = []
    @town_items.push('budget') if Taxonomy.where(:owner => @town.title).first
    @town_items.push('programs') if Programs::Town.where(:name => @town.title).first
    @town_items.push('keys') if @town.key_indicate_map_indicators
    @town_items.push('calendar') if Calendar.where(:town => @town.title).first
    @town_items.push('sankey') if Sankey.where(:owner => @town.title).first
    @town_items.push('repair') if Repairing::Repair.where(:obj_owner => @town.title).first
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
        geo = TownGeojsonBuilder.build(town)
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

  def geo_json_town
    town = Town.find(params[:town_id])
    @geo_json = {
                  "type" => "FeatureCollection",
                  "features" => [TownGeojsonBuilder.build(town)]
              }

    respond_to do |format|
      format.json { render json: @geo_json }
    end
  end

  private

  def set_town
    @town = Town.find(params[:town_id])
    if @town.level == 1 #area
      @towns = Town.all.where(:area_title => @town.title)
    else
      @towns = Town.all.where(:area_title => @town.area_title)
    end
  end

end
