class Programs::IndicatorFilesController < ApplicationController
  before_action :set_programs_indicator_file, only: [:show, :edit, :update, :destroy]
  before_action :set_programs_town, only: [:destroy]

  # GET /programs/indicator_files
  # GET /programs/indicator_files.json
  def index
    @programs_indicator_files = Programs::IndicatorFile.all
  end

  # GET /programs/indicator_files/1
  # GET /programs/indicator_files/1.json
  def show
  end

  # GET /programs/indicator_files/new
  def new
    @programs_indicator_file = Programs::IndicatorFile.new
  end

  # GET /programs/indicator_files/1/edit
  def edit
  end

  # POST /programs/indicator_files
  # POST /programs/indicator_files.json
  def create

    @indicator_files = []
    @programs_town = Programs::Town.where(:id => params[:programs_indicator_file][:town_id]).first

    params['indicator_file'].each do |f|
      doc = Programs::IndicatorFile.new
      doc.indicator_file = f
      doc.programs_town = @programs_town
      doc.title = params[:programs_indicator_file][:title]
      doc.author = current_user.email
      doc.save
      @indicator_files << doc

      table = read_table_from_file 'public/uploads/programs/indicator_file/indicator_file/' + doc._id.to_s + '/' + doc.indicator_file.filename
      doc.import table
      doc.save
    end unless params['indicator_file'].nil?

    respond_to do |format|
      format.js {}
    end

  end

  # PATCH/PUT /programs/indicator_files/1
  # PATCH/PUT /programs/indicator_files/1.json
  def update

    respond_to do |format|
      if @programs_indicator_file.update(programs_indicator_file_params)
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @programs_indicator_file.errors, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /programs/indicator_files/1
  # DELETE /programs/indicator_files/1.json
  def destroy

    @programs_indicator_file.destroy
    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :deleted }
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
    def set_programs_indicator_file
      @programs_indicator_file = Programs::IndicatorFile.find(params[:id])
    end

    def set_programs_town
      @programs_town = @programs_indicator_file.programs_town
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def programs_indicator_file_params
      params.require(:programs_indicator_file).permit(:town_id, :title)
    end
end
