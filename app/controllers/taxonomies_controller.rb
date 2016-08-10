class TaxonomiesController < ApplicationController
  layout 'application_admin'

  before_action :set_taxonomy, only: [:update, :show, :show_modify, :edit, :destroy, :recipients, :recipient_by_code]
  before_action :set_params, only: [:show_modify]
  before_action :set_attachments, only: [:show, :show_modify, :edit]

  before_action :authenticate_user!, except: [:show, :show_modify,:town_profile]
  load_and_authorize_resource


  def recipients
    @recipients = []

    code = @taxonomy.recipients_column

    unless @taxonomy.explanation[code].nil?
      @taxonomy.explanation[code].each { |k, v|
        recipient = @taxonomy.recipients.find_or_create_by(code: k)
        @recipients << { code: recipient[:code], title: v[:title], amount: recipient[:amount] }
      }
    end

    @recipients.sort_by!{ |item| item[:code] }
  end

  def recipient_by_code
    code = params[:code]

    @recipient = @taxonomy.recipients.find_or_create_by(code: code)
    @recipient.amount = taxonomy_params[:recipient_amount]

    respond_to do |format|
      if @recipient.save!
        format.json { render status: :ok }
      else
        format.json { render json: @recipient.errors, status: :unprocessable_entity }
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

  def index
    @taxonomies = Taxonomy.visible_to(current_user).page(params[:page])
  end

  def show
  end

  def show_modify
  end

  def update
    unless params[:taxonomy].nil?
      explanation = @taxonomy.explanation.deep_dup
      params[:taxonomy].each do |key, value|
        value.each { |val_key, val_val|
          val_val.keys.each { |val_key_key|
            explanation[CGI.unescape key][CGI.unescape val_key][CGI.unescape val_key_key] = val_val[CGI.unescape val_key_key]
          }
        }
      end
      @taxonomy.explanation = explanation
      @taxonomy.save
    end


    # @taxonomy.explanation = explanation
    # @taxonomy.save

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

  private

  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end

  def set_params
    @budget_file = @taxonomy

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
    @taxonomy = Taxonomy.find(params[:id]) unless @taxonomy
    @attachments = @taxonomy.taxonomy_attachments
  end

  def taxonomy_params
    params.require(params[:controller].singularize).permit(:title, :name, :description, :is_kvk, :attachment_id, :description, :recipient_amount, :kmb, :active)
  end

end
