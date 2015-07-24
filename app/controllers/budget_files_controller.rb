class BudgetFilesController < ApplicationController

  before_action :set_budget_file, only: [:show, :edit, :update, :destroy, :download]

  before_action :generate_budget_file, only: [:create, :new]
  before_action :set_budget_file_data_type, only: [:new]

  # before_action :update_user_town, only: [:create]

  before_action :authenticate_user!
  # before_action :authenticate_user!, only: [:index, :indicator_file, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /revenues
  # GET / revenues.json
  def index
    @budget_files = BudgetFile.visible_to current_user
  end

  def show
  end

  def new
    @taxonomies = get_taxonomies(current_user.town)
    @current_taxonomy_id = @taxonomies.last.id unless @taxonomies.empty?
  end

  # POST /revenues
  # POST /revenues.json
  def create
    @budget_file.author = current_user.email unless current_user.nil?

    @budget_file.taxonomy = if params[:budget_file_taxonomy].empty?
                              create_taxonomy current_user.town
                            else
                              Taxonomy.find(params[:budget_file_taxonomy])
                            end

    @budget_file.taxonomy.locale = params['locale'] || 'uk'


    @budget_file.data_type = budget_file_params[:data_type].to_sym unless budget_file_params[:data_type].empty?

    file = upload_file budget_file_params[:path]
    file_name = file[:name]
    file_path = file[:path].to_s

    @budget_file.path = file_path

    @budget_file.title = budget_file_params[:title].empty? ? "#{file_name} - #{DateTime.now.strftime('%d-%m-%Y')}" : budget_file_params[:title]

    table = read_table_from_file file_path

    town =
        if UsersHelper.is_admin?(current_user)
          params[:town]
        else
          current_user.town
        end

    @budget_file.import town, table, params[:create_new_taxonomy] == 'true'

    respond_to do |format|
      if @budget_file.save
        format.html { redirect_to @budget_file, notice: t('budget_files_controller.load_success') }
        format.json { render :show, status: :created, location: @budget_file }
      else
        format.html { render :new }
        format.json { render json: @budget_file.errors, status: :unprocessable_entity }
      end
    end
  # rescue => e
  #   respond_to do |format|
  #     format.html { redirect_to budget_files_url, alert: t('budget_files_controller.load_fail') + "#{e}" }
  #     format.json { render json: @budget_file.errors, status: :unprocessable_entity }
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
      format.html { redirect_to budget_files_url, notice: t('budget_files_controller.delete') }
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

  def upload_file uploaded_io
    file_name = uploaded_io.original_filename
    file_path = Rails.root.join('public', 'files', file_name)

    File.open(file_path, 'wb') do |file|
      file.write(uploaded_io.read)
    end

    { name: file_name, path: file_path }
  end

  def read_table_from_file path
    require 'roo'

    case File.extname(path).upcase
      when '.CSV'
        read_csv_xls Roo::CSV.new(path, csv_options: {col_sep: ";"})
      when '.XLS', '.XLSX'
        xls = Roo::Excelx.new(path)
        xls.default_sheet = xls.sheets.first
        read_csv_xls xls
      when '.DBF'
        read_dbf DBF::Table.new(path)
    end
  end

  def read_dbf(dbf)
    cols = dbf.columns.map {|c| c.name}

    rows = dbf.map do |rec|
      row = {}
      cols.each { |col|
        row[col] = rec[col]
      }
      row
    end

    { :rows => rows, :cols => cols }
  end

  def read_csv_xls(xls)
    cols = []
    xls.first_column.upto(xls.last_column) { |col|
      cols << xls.cell(1, col).to_s
    }

    rows = []
    2.upto(xls.last_row) do |line|
      row = {}

      # next if xls.font(line,1).bold?

      xls.first_column.upto(xls.last_column ) do |col|
        row[xls.cell(1, col)] = xls.cell(line,col).to_s
      end
      rows << row
    end

    { :rows => rows, :cols => cols }
  end

  private

  def set_budget_file_data_type
    @budget_file.data_type = params[:data_type].to_sym unless params[:data_type].nil?
  end

  def budget_file_params
    params.require(params[:controller].singularize).permit(:title, :taxonomy, :data_type, :path, :town)
  end

  def set_budget_file
    @budget_file = BudgetFile.find(params[:id] || params[:budget_file_id])
  end

end
