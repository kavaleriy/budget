class TaxonomiesController < ApplicationController

  before_action :set_taxonomy, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!, except: :show
  load_and_authorize_resource

  before_action :set_locale
  def set_locale
    I18n.locale = params[:locale]
  end

  def index
    @taxonomies = view_context.get_taxonomies
  end

  def show
  end

  def update
    respond_to do |format|
      if @taxonomy.update(taxonomy_params)
        format.html { redirect_to @taxonomy, notice: t('taxonomies_controller.save_success') }
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
      format.html { redirect_to taxonomies_path, notice: t('taxonomies_controller.delete_success') }
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
