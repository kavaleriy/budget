class TaxonomiesController < ApplicationController

  before_action :set_taxonomy, only: [:show, :edit, :update, :destroy]
  before_action :set_attachments, only: [:show, :edit]
  before_action :set_attachment, only: [:update_files_description, :delete_attachments, :download_attachments]

  before_action :authenticate_user!, except: :show
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

  def download_attachments
    file_name = @attachment.name
    file_path = get_attachment_path file_name, @taxonomy.id
    if File.exist?(file_path)
      send_file(
          "#{file_path}",
          :x_sendfile=>true
      )
    end
  end

  def upload_files
    taxonomy_id = params[:taxonomy_id]
    @taxonomy = Taxonomy.find(params[:taxonomy_id])
    params[:files].each do |attachment|

      upload_file attachment, taxonomy_id
      file = @taxonomy.taxonomy_attachments.new(
          :name=>attachment.original_filename,
      )

      respond_to do |format|
        if file.save
          format.html {
            render :json => file
          }
        else
          format.json { render json: @attachment.errors, status: :unprocessable_entity }
        end
      end
    end
  end


  def update_files_description
    respond_to do |format|
      @attachment.description = params[:description]
      if @taxonomy.save
        format.json { render json: @attachment }
      else
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end


  def delete_attachments
    file_path = get_attachment_path @attachment.name, @taxonomy.id
    respond_to do |format|
      if File.exist?(file_path)
        if File.delete(file_path)
          @attachment.destroy
          format.json { head "OK" }
        end
      else
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def get_attachment_path filename, taxonomy_id
    Rails.root.join('public', 'files', 'taxonomy_attachments', taxonomy_id, filename)
  end

  def upload_file (attachment, taxonomy_id)

    file_name = attachment.original_filename
    Dir.mkdir('public/files/taxonomy_attachments/' + taxonomy_id) unless File.exists?('public/files/taxonomy_attachments/' + taxonomy_id)
    file_path = get_attachment_path file_name, @taxonomy.id
    File.open(file_path, 'wb') do |file|
      file.write(attachment.read)
    end
  end

  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end

  def set_attachment
    @attachment = @taxonomy.taxonomy_attachments.find(params[:attachment_id])
  end

  def set_attachments
    @attachments = @taxonomy.taxonomy_attachments
  end

  def taxonomy_params
    params.require(params[:controller].singularize).permit(:title, :is_kvk)
  end

end
