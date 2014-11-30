class BudgetFilesController < ApplicationController

  before_action :set_budget_file, only: [:show, :edit, :editinfo, :update, :destroy]

  before_action :authenticate_user!, only: [:index, :upload, :edit, :editinfo]
  load_and_authorize_resource

  # GET /revenues
  # GET / revenues.json
  def index
    @budget_files = view_context.get_budget_files
  end

  def show
  end

  def upload
    @budget_file = BudgetFile.new
  end

  # POST /revenues
  # POST /revenues.json
  def create
    @budget_file = BudgetFile.new if @budget_file.nil?

    @budget_file.owner_email = current_user.email unless current_user.nil?

    file = upload_file budget_file_params[:path]
    file_name = file[:name]
    file_path = file[:path].to_s

    @budget_file.path = file_path

    @budget_file.title = budget_file_params[:title].empty? ? "#{file_name} - #{DateTime.now.strftime('%d-%m-%Y')}" : budget_file_params[:title]

    table = read_table_from_file file_path
    @budget_file.import file_name, table

    respond_to do |format|
      if @budget_file.save
        format.html { redirect_to @budget_file, notice: 'Дані успішно завантажені.' }
        format.json { render :show, status: :created, location: @budget_file }
      else
        format.html { render :new }
        format.json { render json: @budget_file.errors, status: :unprocessable_entity }
      end
    end
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

    # rows = []
    # params[:rows].each { |key, value|
    #   rows[key]['amount'] = value[key].to_i
    # } unless params[:rows].nil?
    # @budget_file.prepare

    @budget_file.taxonomy.explanation = explanation
    @budget_file.save

    respond_to do |format|
      if @budget_file.update(budget_file_params)
      #if @revenue.update(revenue_params.merge({:tree_info => tree_info, :rows => rows}))
        # @budget_file.taxonomy.explanation = explanation
        # @budget_file.taxonomy.save

        format.html { redirect_to @budget_file, notice: 'Дані збережені успішно.' }
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
      format.html { redirect_to budget_files_url, notice: 'Дані успішно видалені.' }
      format.json { head :no_content }
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
      xls.first_column.upto(xls.last_column ) do |col|
        row[xls.cell(1, col)] = xls.cell(line,col).to_s
      end
      rows << row
    end

    { :rows => rows, :cols => cols }
  end


  private

  def set_budget_file
    @budget_file = BudgetFile.find(params[:id])
  end

  def budget_file_params
    params.require(:budget_file).permit(:title, :path)
  end

end
