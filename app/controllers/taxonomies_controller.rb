class TaxonomiesController < ApplicationController

  before_action :set_taxonomy, only: [:show]

  # before_action :authenticate_user!
  # load_and_authorize_resource

  def index
    @taxonomies = Taxonomy.all
  end

  def show
  end


  private

  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end

end
