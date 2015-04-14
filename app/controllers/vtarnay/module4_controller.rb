class Vtarnay::Module4Controller < ApplicationController
  layout 'application_vtarnay'

  before_action :set_taxonomy_file, only: [:show]

  def index
    @taxonomies = TaxonomyRov.all
  end

  def show
  end

  def get_rows
    @budget_file_rov = TaxonomyRov.where(:id => module4_params[:rov_file_id]).first
    render json: { 'rows_rov' => @budget_file_rov.get_first_level("kvk") }
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

  def module4_params
    params.permit(:rov_file_id)
  end

end
