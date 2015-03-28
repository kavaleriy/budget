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
  end
end
