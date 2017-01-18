class Indicate::IndicatorFilesController < ApplicationController
  layout 'application_admin'
  before_action :set_indicate_indicator_file, only: [:show, :edit, :update, :destroy]
  before_action :set_indicate_taxonomy, only: [:create, :destroy]
  before_action :authenticate_user!

  # GET /indicate/indicator_files
  # GET /indicate/indicator_files.json
  def index
    @indicate_indicator_files = Indicate::IndicatorFile.all
  end

  # GET /indicate/indicator_files/1
  # GET /indicate/indicator_files/1.json
  def show
  end

  # GET /indicate/indicator_files/indicator_file
  def indicator_file
    @indicate_indicator_file = Indicate::IndicatorFile.new
  end

  # GET /indicate/indicator_files/1/edit
  def edit
  end

  # POST /indicate/indicator_files
  # POST /indicate/indicator_files.json
  def create

    @indicator_files = []
    if current_user.has_role?(:admin) || params[:town_select]
      @indicate_taxonomy = Indicate::Taxonomy.where(:town => ::Town.where(:id => params[:town_select]).first ).first || Indicate::Taxonomy.new(:town => ::Town.where(:id => params[:town_select]).first)
      @indicate_taxonomy = Indicate::Taxonomy.where(:town => nil).first || Indicate::Taxonomy.create(:town => nil) if @indicate_taxonomy.nil?
    end

    params['indicate_file'].each do |f|
      doc = Indicate::IndicatorFile.new(indicate_indicator_file_params)
      doc.indicate_file = f
      doc.indicate_taxonomy = @indicate_taxonomy
      params[:indicate_indicator_file][:title].blank? ? doc.title = f.original_filename : doc.title = params[:indicate_indicator_file][:title]
      doc.description = params[:indicate_indicator_file][:description]
      doc.author = current_user.email
      doc.save
      @indicator_files << doc

      table = read_table_from_file 'public/uploads/indicate/indicator_file/indicate_file/' + doc._id.to_s + '/' + doc.indicate_file.filename
      doc.import table
    end unless params['indicate_file'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
    end
  end

  # PATCH/PUT /indicate/indicator_files/1
  # PATCH/PUT /indicate/indicator_files/1.json
  def update
    respond_to do |format|
      if @indicate_indicator_file.update(indicate_indicator_file_params)
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @indicate_indicator_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indicate/indicator_files/1
  # DELETE /indicate/indicator_files/1.json
  def destroy
    @indicate_indicator_file.destroy
    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :deleted }
    end
  end

  def get_files
    town = ::Town.find(params[:town])
    @indicate_taxonomy = Indicate::Taxonomy.where(:town => town).first || Indicate::Taxonomy.create(:town => town)
    render :partial => '/indicate/indicator_files/indicator_files', :locals => { :files => @indicate_taxonomy.indicate_indicator_files }
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

  def set_indicate_taxonomy
    if current_user.has_role? :admin
      @indicate_taxonomy = Indicate::Taxonomy.where(:town => ::Town.where(:title => current_user.town).first).first if current_user.town
      @indicate_taxonomy = Indicate::Taxonomy.new(:town => ::Town.new(:title => '')) unless current_user.town.blank?
    else
      @indicate_taxonomy = Indicate::Taxonomy.where(:town_id => ::Town.where(:title => current_user.town).first.id).first
    end

  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def indicate_indicator_file_params
      params.require(:indicate_indicator_file).permit(:indicate_taxonomy_id, :title, :description)
    end
end
