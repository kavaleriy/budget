class TaxonomiesController < ApplicationController

  before_action :set_taxonomy, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @taxonomies = view_context.get_taxonomies
  end

  def show
  end

  def update
    respond_to do |format|
      if @taxonomy.update(taxonomy_params)
        format.html { redirect_to @taxonomy, notice: 'Дані збережені успішно.' }
        format.json { render :show, status: :ok, location: @taxonomy}
      else
        format.html { render :edit }
        format.json { render json: @taxonomy.errors, status: :unprocessable_entity }
      end
    end
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
    params.require(:taxonomy).permit(:title)
  end

end
