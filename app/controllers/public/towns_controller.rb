class Public::TownsController < ApplicationController
  include ControllerCaching
  layout 'town_profile'
  before_action :set_town, only: [:show, :budget]

  before_action :set_documents, only: [:show]

  def index
    @towns = Town.all
  end

  def show
    @calendars = Calendar.where(:town => @town)

    @town_export_budgets = ExportBudget.get_export_budget_by_town(@town)

    @town_links = {}
    if test_town?
      @town_br_links = Documentation::Link.all.where(:town => nil)
    else
      @town_br_links = Documentation::Link.all.where(:town => @town)
    end

    @town.description = get_wiki_town_info(@town.title) || @town.description

    Documentation::LinkCategory.all.each{|br|
      @town_links[br.id.to_s] = {}
      @town_links[br.id.to_s]['title'] = br.title
      @town_links[br.id.to_s]['links'] = @town_br_links.select{|t| t.link_category == br}
    }

  end


  def budget
    # this code for taxonomies dropdown list
    # @taxonomy_rot_list = TaxonomyRot.owned_by(@town.title)
    # @taxonomy_rov_list = TaxonomyRov.owned_by(@town.title)
    # @sankey_url = get_sankey_url_by_taxonomies(@taxonomy_rot_list.first,@taxonomy_rov_list.first)

    # @tabs = []
    #
    # if test_town?
    #   taxonomy_rot = TaxonomyRot.where(:owner => '').first
    #   taxonomy_rov = TaxonomyRov.where(:owner => '').first
    #   sankey = Sankey.where(:owner => '').first
    # else
    #   town = Town.find(params[:town_id])
    #   taxonomy_rot = TaxonomyRot.owned_by(town.to_s).first
    #   taxonomy_rov = TaxonomyRov.owned_by(town.to_s).first
    #   sankey = Sankey.owned_by(town.to_s).first
    # end
    #
    # @tabs << { title: t('.tab_rot'), url: "/widgets/visify/bubbletree/#{taxonomy_rot.id}"} if taxonomy_rot
    # @tabs << { title: t('.tab_rov'), url: "/widgets/visify/bubbletree/#{taxonomy_rov.id}"} if taxonomy_rov
    # @tabs << { title: t('.tab_sankey'), url: "/sankeys/sankey/#{sankey.id}" } if sankey
    #
    # @tabs.first[:cname] = 'active'
  end

  def get_sankey_url_by_taxonomies (tax_rot,tax_rov)
    sankey_url = nil
    sankey = Sankey.by_taxonomies(tax_rot.id,tax_rov.id).first unless tax_rot.nil? && tax_rov.nil?
    sankey_url = get_sankey_path(sankey) unless sankey.nil?
    sankey_url
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

  def get_wiki_town_info(title)
    # API wiki page hash key value if page doesn't exist (-1)
    wiki_page_empty_result = '-1'

    # Wiki-URL town page
    # data_url = "https://uk.wikipedia.org/w/api.php?action=parse&prop=text&format=json&page="
    data_url = "https://uk.wikipedia.org/w/api.php?format=json&action=query&prop=revisions&rvprop=content&rvsection=0&rvparse&titles="

    # encode String to ASCII and concat URL
    uri = URI(data_url + URI.encode("#{title}"))

    # get info from uri
    response = Net::HTTP.get(uri)
    # get needed data from hash with template (template for town)
    result = JSON.parse(response)['query']['pages']

    # data control for existing page in wikipedia
    if result.first[0].eql?(wiki_page_empty_result)
      false
    else
      result.first[1]['revisions'].first['*'].html_safe
    end

  end

  private


  def test_town?
    @town.is_test?
    # params[:town_id] == "test"
  end

  def set_town
    # if test_town?
    #   @town = Town.new(:id => 'test',
    #                    :title => 'Демонстрація типового профілю міста',
    #                    :description => 'Розділ містить короткі відомості про місто, особливості бюджету і т.п...',
    #                    :links => '<a href="http://www.openbudget.in.ua" target="_blank" rel="nofollow">http://www.openbudget.in.ua/</a>')
    # else
      @town = Town.find(params[:town_id])
      if @town.level == 1 #area
        @towns = Town.all.where(:area_title => @town.title)
      else
        @towns = Town.all.where(:area_title => @town.area_title)
      end
    # end
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
end
