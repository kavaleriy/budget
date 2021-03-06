include BudgetFileUpload
class BudgetFilesController < ApplicationController
  layout 'application_admin'

  helper_method :sort_column, :sort_direction
  before_action :set_budget_file, only: [:show, :edit, :update, :destroy, :download]

  # before_action :generate_budget_file, only: [:new]

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

    @budget_files = @budget_files.by_data_type(params['data_type'])   unless params['data_type'].blank?

    @budget_files = @budget_files.find_by_string(params['q'])         unless params['q'].blank?

    taxonomy_ids = @budget_files.pluck(:taxonomy_id)
    file_owners = Taxonomy.by_ids(taxonomy_ids)

    unless params['town_select'].blank?
      file_owners = file_owners.by_towns(params['town_select'])
      @budget_files = @budget_files.by_taxonomy_ids(file_owners.pluck(:_id))
    end

    @budget_files = @budget_files.page(params[:page])
    @file_owners = file_owners.pluck(:id, :owner).to_h

    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
  end

  def new
    @taxonomies = get_taxonomies.map{ |tax| {id: tax.id.to_s, text: tax.title }}
    @budget_file = generate_budget_file nil, nil
  end

  # POST /revenues
  # POST /revenues.json

  def create
    @town = current_user.town

    process_files = -> (files) do
      def process_single_file uploaded
        file_name = uploaded.original_filename
        @file_name = file_name

        new_file_name = get_file_name_for uploaded
        file = upload_file uploaded, new_file_name

        file_path = file[:path].to_s

        if params[:area].blank?
          taxonomy = Taxonomy.find params[:budget_file_taxonomy]
        else
          taxonomy = create_taxonomy(params[:area], file_name)
          taxonomy.town = current_user.town_model
          taxonomy
        end

        @budget_file = generate_budget_file taxonomy, file_name

        fill_budget_file(budget_file_params[:data_type],file_path, taxonomy)
        table = read_table_from_file file_path

        @budget_file.import(table[:rows])

        if @budget_file.taxonomy.columns.blank?
          @budget_file.taxonomy.columns = {}

          column_names = table[:rows].first.keys.reject{|key| %w(_year _month).include? key }
          column_names.delete column_names.last # remove amount

          column_names.map.with_index{ |column, level|
            @budget_file.taxonomy.columns[column] = {:level => level + 1, :title=> column }
          }
        end

        @budget_file.save!
      end

      files.each do |uploaded|
        process_single_file(uploaded) # rescue nil # TODO: logging of files upload
      end
    end

    if (params[:is_deffered])
      Thread.new do
        process_files.call(budget_file_params[:path])
      end
    else
      process_files.call(budget_file_params[:path])
    end

    respond_to do |format|
      if (params[:is_deffered])
        format.html { redirect_to budget_files_path, notice: t('budget_files_controller.load_deffered') }
      else
        format.html { redirect_to @budget_file.taxonomy, notice: t('budget_files_controller.load_success') }
      end

      format.json { render :show, status: :created, location: @budget_file }
    end

  rescue Ole::Storage::FormatError
    message = [t('invalid_format')]
    message << 'Якщо це xls формат переконайтесь у тому що він не xlsx'
    respond_with_error_message(message)
  rescue DBF::Column::NameError
    message = [t('invalid_format')]
    message << 'Допустимі формати .dbf, .xsl, .csv'
    respond_with_error_message(message)
  # rescue => e
  #   message = "Не вдалося створити візуалізацію : #{e}"
  #   respond_with_error_message(message)

  # rescue => e
  #   logger.error "Не вдалося створити візуалізацію. Перевірте коректність змісту завантаженого файлу => #{e}"
  #
  #   respond_to do |format|
  #     format.html { render :new }
  #     format.json { render json: e, status: :unprocessable_entity }
  #   end
  end

  def respond_with_error_message(message)
    respond_to do |format|
      format.html { redirect_to :back, alert:  message }
    end
  end


  # PATCH/PUT /revenues/1
  # PATCH/PUT /revenues/1.json
  def update
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
    # @error = "Вибачте але файл ще не було завантажено"
    @error = t('budget_files_controller.not_download_file')
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

  private

  def fill_budget_file(data_type,file_path,taxonomy)
    # this function fill budget_file model
    # get three parameters data_type and file_path
    # data_type is budget_file.type(can be 'plan' or 'fact')
    # file_path is path to file,when he will be saved
    # taxonomy is taxonomy what has this budget_file(one taxonomy -> many budget_file)
    @budget_file.taxonomy = taxonomy
    @budget_file.taxonomy.author = current_user
    @budget_file.author_model = current_user
    @budget_file.author = current_user.email unless current_user.nil?

    @budget_file.data_type = data_type.to_sym unless data_type.nil?

    @budget_file.path = file_path

    @budget_file.title = "#{get_file_title} - #{DateTime.now.strftime('%d-%m-%Y')}"
    @budget_file.name = @file_name if @budget_file.name.nil?
  end

  # def set_taxonomy_by_budget_file(taxonomy_id)
  #   taxonomy = Taxonomy.where(id: taxonomy_id).first
  #   if taxonomy.nil?
  #     taxonomy = create_taxonomy
  #
  #     taxonomy.town = @town
  #     taxonomy
  #   else
  #     Taxonomy.where(id: taxonomy_id).first
  #   end
  # end
  #

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
