class Public::TownsController < ApplicationController
  include ControllerCaching

  layout 'application_public'

  before_action :set_town, only: [:show]

  def index
    @towns = Town.all
  end

  def show
    @calendars = Calendar.where(:town => @town)
    @branches = {}
    Documentation::Branch.all.each{|br|
      @branches[br.id.to_s] = {}
      @branches[br.id.to_s]['title'] = br.title
      @branches[br.id.to_s]['count'] = @documents.select{|t| t.branch == br}.length
    }
    @town_links = {}
    if @town.blank?
      @town_br_links = Documentation::Link.all.where(:town => nil)
    else
      @town_br_links = Documentation::Link.all.where(:town => @town)
    end

    Documentation::LinkCategory.all.each{|br|
      @town_links[br.id.to_s] = {}
      @town_links[br.id.to_s]['title'] = br.title
      @town_links[br.id.to_s]['links'] = @town_br_links.select{|t| t.link_category == br}

    }
    town = ''
    town = @town.title unless @town.blank?
    @budgets = Taxonomy.where(:owner => town)
    @total_amounts = {}
    @budgets.each{|budget|
      @total_amounts[budget._type] = budget.get_total_amounts
    }
    @town_items = []
    @town_items.push('budget') if Taxonomy.where(:owner => town).first
    @town_items.push('programs') if Programs::Town.where(:name => town).first
    @town_items.push('calendar') if Calendar.where(:town => town).first
    @town_items.push('sankey') if Sankey.where(:owner => town).first
    @town_items.push('repair')
    @town_items.push('purchase')
    if @town.blank?
      @town_items.push('keys')
      @town = Town.new(:id => 'test',
                       :title => 'Демонстрація типового профілю міста',
                       :description => 'Розділ містить короткі відомості про місто, особливості бюджету і т.п...',
                       :links => '<a href="http://www.openbudget.in.ua" target="_blank" rel="nofollow">http://www.openbudget.in.ua/</a>')
      @town_items.push('indicators') if Indicate::Taxonomy.where(:town => nil)
    else
      @town_items.push('keys') if @town.key_indicate_map_indicators
      @town_items.push('indicators') if Indicate::Taxonomy.where(:town => town)
    end

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
    if params[:town_id] == "test"
      @town = ''
      @documents = Documentation::Document.all.select{|t| t.town.nil?}
    else
      @town = Town.find(params[:town_id])
      @documents = Documentation::Document.all.select{|t| t.town == @town}
      if @town.level == 1 #area
        @towns = Town.all.where(:area_title => @town.title)
      else
        @towns = Town.all.where(:area_title => @town.area_title)
      end
    end
  end

end
