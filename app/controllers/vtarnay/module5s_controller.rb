class Vtarnay::Module5sController < ApplicationController
  before_action :set_vtarnay_module5, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!
  # load_and_authorize_resource

  # GET /vtarnay/module5s
  # GET /vtarnay/module5s.json
  def index
    @vtarnay_module5s = Vtarnay::Module5.all
  end

  # GET /vtarnay/module5s/1
  # GET /vtarnay/module5s/1.json
  def show
    town = current_user.town unless current_user.nil?
    @vtarnay_module5s = Vtarnay::Module5.all.where(:town => town)
    @rows = {}
    @vtarnay_module5s.each{|file|
      file['rows'].each {|row|
        row.each{|data|
          if data['value']
            if @rows[data['group']].nil?
              @rows[data['group']] = {}
            end
            if @rows[data['group']][data['indicator']].nil?
              @rows[data['group']][data['indicator']] = {}
            end
            year = data['year'].to_i
            @rows[data['group']][data['indicator']][year] = {}
            @rows[data['group']][data['indicator']][year]['comments'] = data['comments']
            @rows[data['group']][data['indicator']][year]['value'] = data['value']
          end
        }
      }
    }
  end

  # GET /vtarnay/module5s/new
  def new
    @vtarnay_module5 = Vtarnay::Module5.new
  end

  # GET /vtarnay/module5s/1/edit
  def edit
  end

  # POST /vtarnay/module5s
  # POST /vtarnay/module5s.json
  def create
    @vtarnay_module5 = Vtarnay::Module5.new(vtarnay_module5_params)

    @vtarnay_module5.author = current_user.email unless current_user.nil?
    @vtarnay_module5.town = current_user.town unless current_user.nil?

    file = upload_file vtarnay_module5_params[:path]
    file_name = file[:name]
    file_path = file[:path].to_s

    @vtarnay_module5.path = file_path

    @vtarnay_module5.title = vtarnay_module5_params[:title].empty? ? "#{file_name} - #{DateTime.now.strftime('%d-%m-%Y')}" : vtarnay_module5_params[:title]

    table = read_table_from_file file_path

    @vtarnay_module5.import table

    respond_to do |format|
      if @vtarnay_module5.save
        format.html { redirect_to @vtarnay_module5, notice: 'Module5 was successfully created.' }
        format.json { render :show, status: :created, location: @vtarnay_module5 }
      else
        format.html { render :new }
        format.json { render json: @vtarnay_module5.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vtarnay/module5s/1
  # PATCH/PUT /vtarnay/module5s/1.json
  def update
    respond_to do |format|
      if @vtarnay_module5.update(vtarnay_module5_params)
        format.html { redirect_to @vtarnay_module5, notice: 'Module5 was successfully updated.' }
        format.json { render :show, status: :ok, location: @vtarnay_module5 }
      else
        format.html { render :edit }
        format.json { render json: @vtarnay_module5.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vtarnay/module5s/1
  # DELETE /vtarnay/module5s/1.json
  def destroy
    @vtarnay_module5.destroy
    respond_to do |format|
      format.html { redirect_to vtarnay_module5s_url, notice: 'Module5 was successfully destroyed.' }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_vtarnay_module5
      @vtarnay_module5 = Vtarnay::Module5.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vtarnay_module5_params
      params.require(:vtarnay_module5).permit(:title, :path)
    end
end
