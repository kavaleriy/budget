include BudgetFileUpload
class BudgetFilesController < ApplicationController
  layout 'application_admin'

  helper_method :sort_column, :sort_direction
  before_action :set_budget_file, only: [:show, :edit, :update, :destroy, :download]

  before_action :generate_budget_file, only: [:new]

  # before_action :update_user_town, only: [:create]

  before_action :authenticate_user!
  load_and_authorize_resource

  after_action :clear_cache, only: [:create, :update, :delete]

  def clear_cache
    Rails.cache.clear
  end

  # GET /revenues
  # GET / revenues.json
  def index
    @budget_files = BudgetFile.only(:id, :taxonomy_id, :title, :name, :data_type, :author).visible_to(current_user)

    case sort_column
      when "title"
        @budget_files.sort_by{|b| b.title || '' }
      when "taxonomy.owner"
        @budget_files.sort_by{|b| b.taxonomy.owner }
      when "data_type"
        @budget_files.sort_by{|b| b.data_type.to_s }
      when "author"
        @budget_files.sort_by{|b| b.author }
    end
    @budget_files.reverse! if sort_direction == "desc"

    @budget_files = @budget_files.where(:data_type => params['data_type'].to_sym) unless params["data_type"].blank?
    unless params["q"].blank?
      @budget_files = @budget_files.where(:title => /.*#{params['q']}.*/)
    end


    taxonomy_ids = @budget_files.pluck(:taxonomy_id)
    file_owners = Taxonomy.where(:id.in => taxonomy_ids)

    unless params["town_select"].blank?
      towns = []
      params["town_select"].split(",").each{|town_id|
        towns << Town.find(town_id).title
      }
      file_owners = file_owners.where(:owner.in => towns)
    end

    @file_owners = file_owners.pluck(:id, :owner).to_h

    respond_to do |format|
      format.js
      format.html
    end

  end

  def show
  end

  def new
    @taxonomies = get_taxonomies(current_user.town)
    @current_taxonomy_id = @taxonomies.last.id unless @taxonomies.blank?
  end

  # POST /revenues
  # POST /revenues.json

  def create
    @town_title = params['town_select'].blank? ? current_user.town : params['town_select']

    budget_file_params[:path].each do |uploaded|
      @file_name = uploaded.original_filename

      new_file_name = get_file_name_for uploaded
      file = upload_file uploaded, new_file_name

      file_path = file[:path].to_s

      @taxonomy = params[:budget_file_taxonomy].blank? ? create_taxonomy : Taxonomy.find(params[:budget_file_taxonomy])
      @taxonomy.locale = params['locale'] || 'uk'

      generate_budget_file

      @budget_file.taxonomy = @taxonomy
      @budget_file.author = current_user.email unless current_user.nil?

      @budget_file.data_type = budget_file_params[:data_type].to_sym unless budget_file_params[:data_type].nil?

      @budget_file.path = file_path

      @budget_file.title = "#{get_file_title} - #{DateTime.now.strftime('%d-%m-%Y')}"
      @budget_file.name = @file_name if @budget_file.name.nil?

      table = read_table_from_file file_path

      @budget_file.import table

      @budget_file.save!
    end

    respond_to do |format|
      format.html { redirect_to @budget_file.taxonomy, notice: t('budget_files_controller.load_success') }
      format.json { render :show, status: :created, location: @budget_file }
    end
  # rescue => e
  #   logger.error "Не вдалося створити візуалізацію. Перевірте коректність змісту завантаженого файлу => #{e}"
  #
  #   respond_to do |format|
  #     format.html { render :new }
  #     format.json { render json: e, status: :unprocessable_entity }
  #   end
  end

  # PATCH/PUT /revenues/1
  # PATCH/PUT /revenues/1.json
  def update
    taxonomy = @budget_file.taxonomy
    explanation = taxonomy.explanation.deep_dup
    params[:taxonomy].each do |key, value|
      value.each { |val_key, val_val|
        val_val.keys.each { |val_key_key|
          explanation[CGI.unescape key][CGI.unescape val_key][CGI.unescape val_key_key] = val_val[CGI.unescape val_key_key]
        }
      }
    end unless params[:taxonomy].nil?

    @budget_file.taxonomy.explanation = explanation
    @budget_file.save

    respond_to do |format|
      if @budget_file.update(budget_file_params)
      #if @revenue.update(revenue_params.merge({:tree_info => tree_info, :rows => rows}))
        # @budget_file.taxonomy.explanation = explanation
        # @budget_file.taxonomy.save

        format.html { redirect_to @budget_file, notice: t('budget_files_controller.save') }
        format.json { render :show, status: :ok, location: @budget_file }
      else
        format.html { render :edit }
        format.json { render json: @budget_file.errors, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /revenues/1
  # DELETE /revenues/1.json
  def destroy
    @budget_file.destroy
    respond_to do |format|
      format.html { redirect_to budget_files_path, notice: 'BudgetFile was successfully destroyed.' }
      format.js
      format.json { head :no_content }
    end
  end

  def download
    file_path = @budget_file.path
    if File.exist?(file_path)
      send_file(
          "#{file_path}",
          :x_sendfile=>true
      )
    end
  end

  protected

  def get_file_title
    @file_name
  end

  def get_file_name_for uploaded_io
    uploaded_io.original_filename
  end

  def generate_budget_file
    @budget_file = BudgetFile.new
  end

  private

  def sort_column
    params[:sort] ? params[:sort] : "title"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


  def budget_file_params
    params.require(params[:controller].singularize).permit(:taxonomy, :data_type, :town, :path => [])
  end

  def set_budget_file
    @budget_file = BudgetFile.find(params[:id] || params[:budget_file_id])
  end

end
