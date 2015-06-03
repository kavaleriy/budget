class Indicate::IndicatorFilesController < ApplicationController
  before_action :set_indicate_indicator_file, only: [:show, :edit, :update, :destroy]

  # GET /indicate/indicator_files
  # GET /indicate/indicator_files.json
  def index
    @indicate_indicator_files = Indicate::IndicatorFile.all
  end

  # GET /indicate/indicator_files/1
  # GET /indicate/indicator_files/1.json
  def show
  end

  # GET /indicate/indicator_files/new
  def new
    @indicate_indicator_file = Indicate::IndicatorFile.new
  end

  # GET /indicate/indicator_files/1/edit
  def edit
  end

  # POST /indicate/indicator_files
  # POST /indicate/indicator_files.json
  def create
    @indicator_files = []

    taxonomy = Indicate::Taxonomy.where(:town => current_user.town).first

    if taxonomy.nil?
      taxonomy = Indicate::Taxonomy.new(:town => current_user.town)
    end

    params['indicate_file'].each do |f|
      doc = Indicate::IndicatorFile.new(indicate_indicator_file_params)
      doc.indicate_file = f
      doc.indicate_taxonomy = taxonomy
      doc.author = current_user.email
      doc.save
      @indicator_files << doc

      table = read_table_from_file 'public/uploads/indicate/indicator_file/indicate_file/' + doc._id.to_s + '/' + doc.indicate_file.filename
      doc.import table
    end unless params['indicate_file'].nil?

    respond_to do |format|
      format.js {
      }
      format.json { head :no_content, status: :created }
    end
  end

  # PATCH/PUT /indicate/indicator_files/1
  # PATCH/PUT /indicate/indicator_files/1.json
  def update
    respond_to do |format|
      if @indicate_indicator_file.update(indicate_indicator_file_params)
        format.html { redirect_to @indicate_indicator_file, notice: 'Indicator file was successfully updated.' }
        format.json { render :show, status: :ok, location: @indicate_indicator_file }
      else
        format.html { render :edit }
        format.json { render json: @indicate_indicator_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indicate/indicator_files/1
  # DELETE /indicate/indicator_files/1.json
  def destroy
    @indicate_indicator_file.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  protected

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
    def set_indicate_indicator_file
      @indicate_indicator_file = Indicate::IndicatorFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def indicate_indicator_file_params
      params.require(:indicate_indicator_file).permit(:indicate_taxonomy_id, :title, :description)
    end
end
