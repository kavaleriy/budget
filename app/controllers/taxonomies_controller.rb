class TaxonomiesController < ApplicationController

  before_action :set_taxonomy, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @taxonomies = Taxonomy.all
  end

  def show
  end

  def destroy
    @taxonomy.destroy
    respond_to do |format|
      format.html { redirect_to taxonomies_path, notice: 'Дані успішно видалені.' }
      format.json { head :no_content }
    end
  end


  private

  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end

  def taxonomy_params
    binding.pry
    params.require(:taxonomy).permit(:title)
  end

end
