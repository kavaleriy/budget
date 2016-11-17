class Public::TownsController < ApplicationController
  include ControllerCaching
  layout 'town_profile'
  before_action :set_town, only: [:show, :budget,:render_docs]

  before_action :set_documents, only: [:show,:render_docs]

  def index
    @towns = Town.all
  end

  def show
    # Now this query not use
    # @calendars = Calendar.where(town_model_id: @town)

    @town_export_budgets = ExportBudget.get_export_budget_by_town(@town)

    @town_links = Documentation::Link.get_hash_links_by_town(@town)

  end

  def render_docs
    respond_to do |format|
      format.js {render 'public/towns/documents/render_docs'}
    end
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

  private


  def test_town?
    @town.is_test?
  end

  def set_town
      @town = Town.find(params[:town_id])
      if @town.level == 1 #area
        @towns = Town.all.where(:area_title => @town.title)
      else
        @towns = Town.all.where(:area_title => @town.area_title)
      end
  end

  def set_documents
    @documents = Documentation::Document.get_grouped_documents_for_town(@town)
  end
end
