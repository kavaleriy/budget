class Public::TownsController < ApplicationController
  include ControllerCaching

  before_action :set_town, only: [:show, :budget]

  before_action :set_documents, only: [:show]

  def index
    @towns = Town.all
  end

  def show
    @export_budget = ExportBudget.new

    @export_budgets = ExportBudget.all

    @calendars = Calendar.where(:town => @town)

    @town_export_budgets = ExportBudget.where(:town => @town.id)

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
    # @town_items = get_town_items(@town)
  end


  def budget
    @tabs = []

    if params[:town_id] == 'test'
      taxonomy_rot = TaxonomyRot.where(:owner => '').first
      taxonomy_rov = TaxonomyRov.where(:owner => '').first
      sankey = Sankey.where(:owner => '').first
    else
      town = Town.find(params[:town_id])
      taxonomy_rot = TaxonomyRot.where(:owner => town.title).first
      taxonomy_rov = TaxonomyRov.where(:owner => town.title).first
      sankey = Sankey.where(:owner => town.title).first
    end

    @tabs << { title: t('.tab_rot'), url: "/widgets/visify/bubbletree/#{taxonomy_rot.id}"} if taxonomy_rot
    @tabs << { title: t('.tab_rov'), url: "/widgets/visify/bubbletree/#{taxonomy_rov.id}"} if taxonomy_rov
    @tabs << { title: t('.tab_sankey'), url: "/sankeys/sankey/#{sankey.id}"} if sankey
    @tabs.first[:cname] = 'active'
  end
  def pdf_docs
    abort 'dsada'
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
      towns.reject{|town| (town.level != 1 && town.level != 13) }.each do |town|
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

  def test_town?
    params[:town_id] == "test"
  end

  def set_town
    if test_town?
      @town = ''
    else
      @town = Town.find(params[:town_id])
      if @town.level == 1 #area
        @towns = Town.all.where(:area_title => @town.title)
      else
        @towns = Town.all.where(:area_title => @town.area_title)
      end
    end
  end

  def set_documents
    if test_town?
      @documents = Documentation::Document.all.select{|t| t.town.nil?}
    else
      @documents = Documentation::Document.where(locked: false)
      @documents = @documents.select{ |doc| params[:town_id].include? doc.town_id.to_s }

      @documents.sort_by!{|doc| doc.title ? doc.title : ""  }
    end
  end

  def get_town_items town_object
    town_items = Town.get_town_items_hash(town_object)
    town_items
  end
end
