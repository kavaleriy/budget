class KeyIndicate::TownsController < ApplicationController
  before_action :set_key_indicate_town, only: [:show, :reset_table, :edit, :update, :destroy, :indicator_file_destroy]
  before_action :set_indicator_files, only: [:show, :edit]
  before_action :set_indicator_file, only: [:update_files_description, :delete_attachments, :download_attachments]

  before_action :authenticate_user!, only: [:new, :edit]
  load_and_authorize_resource
  before_action :create_indicate_town, only: [:new]

  # GET /key_indicate/towns
  # GET /key_indicate/towns.json
  def index
    @key_indicate_towns = KeyIndicate::Town.all
  end

  # GET /key_indicate/towns/1
  # GET /key_indicate/towns/1.json
  def show
    $key_indicators = @key_indicate_town.get_indicators
  end

  def reset_table
    render :partial => '/key_indicate/towns/indicators_table', :locals => {:indicators => $key_indicators[params[:year].to_i], :town => @key_indicate_town.title }
  end

  # GET /key_indicate/towns/new
  def new
  end

  def add_files
    @key_indicate_town = KeyIndicate::Town.where(:id => params[:town]).first
  end

  # GET /key_indicate/towns/1/edit
  def edit
  end

  # POST /key_indicate/towns
  # POST /key_indicate/towns.json
  def create
    @key_indicate_town = KeyIndicate::Town.new(key_indicate_town_params)

    respond_to do |format|
      if @key_indicate_town.save
        format.html { redirect_to @key_indicate_town, notice: 'Town was successfully created.' }
        format.json { render :show, status: :created, location: @key_indicate_town }
      else
        format.html { render :new }
        format.json { render json: @key_indicate_town.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /key_indicate/towns/1
  # PATCH/PUT /key_indicate/towns/1.json
  def update
    respond_to do |format|
      if @key_indicate_town.update_explanation(params[:town][:explanation])
        format.html { redirect_to @key_indicate_town, notice: 'Town was successfully updated.' }
        format.json { render :show, status: :ok, location: @key_indicate_town }
      else
        format.html { render :edit }
        format.json { render json: @key_indicate_town.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /key_indicate/towns/1
  # DELETE /key_indicate/towns/1.json
  def destroy
    @key_indicate_town.destroy
    respond_to do |format|
      format.html { redirect_to key_indicate_towns_url, notice: 'Town was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def indicator_file_create
    @indicator_files = []

    if current_user.has_role? :admin
      @key_indicate_town = KeyIndicate::Town.where(:title => params[:town]).first
      if @key_indicate_town.nil?
        @key_indicate_town = KeyIndicate::Town.new(:title => params[:town])
        @key_indicate_town.generate_explanation
        @key_indicate_town.save
      end
    end

    params['indicate_file'].each do |f|
      doc = KeyIndicate::IndicatorFile.new
      doc.indicate_file = f
      params[:key_indicate_town][:title].present? ? doc.title = params[:key_indicate_town][:title] : doc.title = f.original_filename
      doc.key_indicate_town = @key_indicate_town
      doc.author = current_user.email
      doc.save
      @indicator_files << doc

      table = read_table_from_file 'public/uploads/key_indicate/indicator_file/indicate_file/' + doc._id.to_s + '/' + doc.indicate_file.filename
      doc.import table
    end unless params['indicate_file'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
    end
  end

  def indicator_file_update
    indicator_file = KeyIndicate::IndicatorFile.where(:id => params[:indicator_file_id])
    respond_to do |format|
      if indicator_file.update(params[:key_indicate_indicator_file])
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @key_indicate_town.errors, status: :unprocessable_entity }
      end
    end
  end

  def indicator_file_destroy
    indicator_file = KeyIndicate::IndicatorFile.where(:id => params[:indicator_file_id]).first
    indicator_file.destroy
    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :deleted }
    end
  end

  def get_files
    @key_indicate_town = KeyIndicate::Town.where(:title => params[:town]).first || KeyIndicate::Town.new(:title => params[:town])
    render :partial => '/key_indicate/towns/indicator_files', :locals => {:town => @key_indicate_town, :files => @key_indicate_town.key_indicate_indicator_files }
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
    def create_indicate_town
      @key_indicate_town = KeyIndicate::Town.where(:title => current_user.town).first
      if @key_indicate_town.nil?
        @key_indicate_town = KeyIndicate::Town.new(:title => current_user.town)
        @key_indicate_town.generate_explanation
        @key_indicate_town.save
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_key_indicate_town
      @key_indicate_town = KeyIndicate::Town.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_indicate_town_params
      params.require(:key_indicate_town).permit(:title, :indicator_file_id, :description)
    end

    def set_indicator_file
      @indicator_file = @key_indicate_town.key_indicate_indicator_files.find(params[:indicator_file_id])
    end

    def set_indicator_files
      @indicator_files = @key_indicate_town.key_indicate_indicator_files
    end
end
