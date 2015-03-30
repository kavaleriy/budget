class Vtarnay::Module4Controller < ApplicationController
  layout 'application_vtarnay'

  before_action :set_taxonomy_file, only: [:show]

  def index
    @taxonomies = Taxonomy.all
  end

  def show
  end

  private

  def set_taxonomy_file
    @taxonomy = Taxonomy.find(params[:id])

    @sel_year = '0'
    @sel_month = '0'

    range = {}
    @taxonomy.get_range.each{ |item| item.each{ |k, v| range[k] = v } }
    @range = range.sort_by{|k,v| k.to_i}

    @sel_year = @range.last[0]
    @sel_month = @range.last[1].first
  end

end
