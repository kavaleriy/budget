class TaxonomiesController < ApplicationController

  before_action :set_taxonomy, only: [:show, :show_modify, :edit, :update, :destroy]
  before_action :set_params, only: [:show_modify]
  before_action :set_attachments, only: [:show, :show_modify, :edit]

  before_action :authenticate_user!, except: [:show, :show_modify, :town_profile]
  load_and_authorize_resource

  def index
    @taxonomies = Taxonomy.visible_to current_user
  end

  def show
  end

  def show_modify
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
      format.js
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
        format.json { render json: @taxonomy.errors, status: :unprocessable_entity }
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

  def acceptors_file_create
    @acceptors_files = []
    taxonomy_type = @taxonomy.class.to_s.split(/(?=[A-Z])/).join('_').downcase!

    params['acceptors_file'].each do |f|
      doc = TaxonomyAcceptorsFile.new
      doc.acceptors_file = f
      params[taxonomy_type][:taxonomy_acceptors_files][:title].blank? ? doc.title = f.original_filename : doc.title = params[taxonomy_type][:taxonomy_acceptors_files][:title]
      doc.taxonomy = @taxonomy
      doc.author = current_user.email
      doc.save
      @acceptors_files << doc

      table = read_table_from_file 'public/uploads/taxonomy_acceptors_file/acceptors_file/' + doc._id.to_s + '/' + doc.acceptors_file.filename

      doc.import table

    end unless params['acceptors_file'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
    end
  end

  def acceptors_file_destroy
    acceptors_file = TaxonomyAcceptorsFile.where(:id => params[:acceptors_file_id])
    acceptors_file.destroy
    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :deleted }
    end
  end

  def acceptors_file_update
    acceptors_file = TaxonomyAcceptorsFile.where(:id => params[:acceptors_file_id])

    respond_to do |format|
      if acceptors_file.update(params[:taxonomy_acceptors_file])
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @taxonomy.errors, status: :unprocessable_entity }
      end
    end
  end

  def town_profile
    if params[:town_id] == 'test'
      @taxonomy = Taxonomy.where(:owner => '').first
    else
      town = Town.find(params[:town_id])
      @taxonomy = Taxonomy.where(:owner => town.title).first
    end
    render 'show'
  end

  private

  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end

  def set_params
    @budget_file = @taxonomy
    @data_type = 'plan'

    @levels = @taxonomy.columns.keys
    @file_type = @taxonomy._type
    @types_count = @taxonomy.budget_files.group_by{|f| f.data_type}.count

    @sel_year = '0'
    @sel_month = '0'

    @range = {}
    range = {}
    @taxonomy.get_range.each{ |item| item.each{ |k, v| range[k] = v } }
    @range = range.sort_by{|k,v| k.to_i}

    @sel_year = @range.last[0]
    @sel_month = @range.last[1].first

    @fond_codes = Taxonomy.fond_codes(params['locale'] || 'uk')

  rescue => e
    logger.error "Не вдалося створити візуалізацію. Перевірте коректність змісту завантаженого файлу => #{e}"
  end

  def set_attachments
    @attachments = @taxonomy.taxonomy_attachments
    @acceptors_files = @taxonomy.taxonomy_acceptors_files
  end

  def taxonomy_params
    params.require(params[:controller].singularize).permit(:title, :description, :is_kvk, :attachment_id, :acceptors_file_id, :description)
  end

end
