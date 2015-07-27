class KeyIndicate::TownsController < ApplicationController
  before_action :set_key_indicate_town, only: [:show, :edit, :update, :destroy, :indicator_file_destroy]
  before_action :set_indicator_files, only: [:show, :edit]
  before_action :set_indicator_file, only: [:update_files_description, :delete_attachments, :download_attachments]

  before_action :authenticate_user!, only: [:new, :edit]
  load_and_authorize_resource
  before_action :create_indicate_town, only: [:new]

  # GET /key_indicate/towns
  # GET /key_indicate/towns.json
  def index
    key_towns = KeyIndicate::Town.all.reject{|t| t.key_indicate_indicator_files.length <= 0}
    @towns = []
    key_towns.each{|town|
      @towns.push([town.title, town.id])
    }
    $indicators = KeyIndicate::Dictionary.first.get_keys
  end

  # GET /key_indicate/towns/1
  # GET /key_indicate/towns/1.json
  def show
    $key_indicators = {}
    add_town_indicators @key_indicate_town
    @key_indicate_town.key_indicate_town.each{|key_town|
      add_town_indicators key_town
    }
  end

  def add_town_indicators new_town
    indicators = new_town.get_indicators
    town = new_town.title
    indicators.each{|year, value|
      $key_indicators[year] = {} if $key_indicators[year].nil?
      value.each{|k, v|
        case v['type']
          when 'to_f'
            amount = v['amount'].to_f
          when 'to_i'
            amount = v['amount'].to_i
        end
        $key_indicators[year][k] = {} if $key_indicators[year][k].nil?
        $key_indicators[year][k]['name'] = v['name'] if $key_indicators[year][k]['name'].nil?
        $key_indicators[year][k]['icon'] = v['icon'] if $key_indicators[year][k]['icon'].nil?
        $key_indicators[year][k]['color'] = v['color'] if $key_indicators[year][k]['color'].nil?
        $key_indicators[year][k]['max_amount'] = 0 if $key_indicators[year][k]['max_amount'].nil?
        $key_indicators[year][k]['max_amount'] = amount if amount > $key_indicators[year][k]['max_amount']
        $key_indicators[year][k]['towns'] = {} if $key_indicators[year][k]['towns'].nil?
        $key_indicators[year][k]['towns'][town] = {}
        $key_indicators[year][k]['towns'][town]['amount'] = amount
        $key_indicators[year][k]['towns'][town]['description'] = v['description']
      }
    }
  end

  def reset_table
    params[:data].each{|title|
      town = KeyIndicate::Town.where(:title => title).first
      town.get_indicators(params[:year].to_i).each{|key, value|
        if $indicators[key]['type'] == 'to_i'
          amount = value['amount'].to_i
        else
          amount = value['amount'].to_f
        end
        $indicators[key]['max_amount'] = 0 if $indicators[key]['max_amount'].nil?
        $indicators[key]['towns'] = {} if $indicators[key]['towns'].nil?
        $indicators[key]['towns'][title] = {} if $indicators[key]['towns'][title].nil?
        $indicators[key]['towns'][title]['amount'] = amount
        $indicators[key]['max_amount'] = amount if amount > $indicators[key]['max_amount']
        $indicators[key]['towns'][title]['description'] = value['description']
      }
    }
    render :partial => '/key_indicate/towns/indicators_table', :locals => {:indicators => $indicators, :towns => params[:data]}
  end

  # GET /key_indicate/towns/new
  def new
  end

  def add_files
    @key_indicate_town = KeyIndicate::Town.where(:id => params[:town]).first
  end

  # GET /key_indicate/towns/1/edit
  def edit
    @towns = KeyIndicate::Town.all.reject{|t| t.key_indicate_indicator_files.length <= 0 || t == @key_indicate_town }.collect { |t| [t.title, t.id] }
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
    @key_indicate_town.key_indicate_town = []
    if params['compare_towns']
      compare_towns = params['compare_towns']
      compare_towns.each{|town|
        @key_indicate_town.key_indicate_town.push(KeyIndicate::Town.find(town))
      }
    end

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
        @key_indicate_town.save
      end
    end

    params['indicate_file'].each do |f|
      doc = KeyIndicate::IndicatorFile.new
      doc.indicate_file = f
      params[:key_indicate_indicator_files][:title].blank? ? doc.title = f.original_filename : doc.title = params[:key_indicate_indicator_files][:title]
      doc.description = params[:key_indicate_indicator_files][:description]
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
        # @key_indicate_town.generate_explanation
        @key_indicate_town.save
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_key_indicate_town
      @key_indicate_town = KeyIndicate::Town.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_indicate_town_params
      params.require(:key_indicate_town).permit(:year, :title, :indicator_file_id, :description)
    end

    def set_indicator_file
      @indicator_file = @key_indicate_town.key_indicate_indicator_files.find(params[:indicator_file_id])
    end

    def set_indicator_files
      @indicator_files = @key_indicate_town.key_indicate_indicator_files
    end
end
