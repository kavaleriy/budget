class TaxonomiesController < ApplicationController

  before_action :set_taxonomy, only: [:show, :edit, :update, :destroy]
  before_action :set_attachments, only: [:show, :edit]
  before_action :set_attachment, only: [:update_files_description, :delete_attachments, :download_attachments]

  before_action :authenticate_user!, except: [:show, :download_attachments]
  load_and_authorize_resource

  before_action :set_locale
  def set_locale
    I18n.locale = params[:locale]
  end

  def index
    @taxonomies = Taxonomy.visible_to current_user
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

  def attachment_destroy
    attachment = TaxonomyAttachment.where(:id => params[:attachment_id])
    attachment.destroy
    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :deleted }
    end
  end

  def attachment_update
    attachment = TaxonomyAttachment.where(:id => params[:attachment_id])
    respond_to do |format|
      if attachment.update(params[:taxonomy_attachment])
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @indicate_indicator_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def attachment_create
    @attachments = []
    taxonomy_type = @taxonomy.class.to_s.split(/(?=[A-Z])/).join('_').downcase!

    params['attachment'].each do |f|
      doc = TaxonomyAttachment.new
      doc.attachment = f
      params[taxonomy_type][:taxonomy_attachments][:title].blank? ? doc.title = f.original_filename : doc.title = params[taxonomy_type][:taxonomy_attachments][:title]
      doc.description = params[taxonomy_type][:taxonomy_attachments][:description]
      doc.taxonomy = @taxonomy
      doc.author = current_user.email
      doc.save
      @attachments << doc

    end unless params['attachment'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
    end
  end

  private

  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end

  def set_attachment
    @taxonomy = Taxonomy.find(params[:taxonomy_id])
    @attachment = @taxonomy.taxonomy_attachments.find(params[:attachment_id])
  end

  def set_attachments
    @attachments = @taxonomy.taxonomy_attachments
  end

  def taxonomy_params
    params.require(params[:controller].singularize).permit(:title, :is_kvk, :attachment_id, :description)
  end

end
