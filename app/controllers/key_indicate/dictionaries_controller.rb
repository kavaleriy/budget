class KeyIndicate::DictionariesController < ApplicationController
  before_action :set_key_indicate_dictionary, only: [:show, :edit, :update, :destroy, :dictionary_file_create, :dictionary_file_update, :dictionary_file_destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /key_indicate/dictionaries
  # GET /key_indicate/dictionaries.json
  def index
    @key_indicate_dictionary = KeyIndicate::Dictionary.first || KeyIndicate::Dictionary.create
    @keys = @key_indicate_dictionary.key_indicate_dictionary_files
  end

  # GET /key_indicate/dictionaries/1
  # GET /key_indicate/dictionaries/1.json
  def show
  end

  # GET /key_indicate/dictionaries/new
  def new
    @key_indicate_dictionary = KeyIndicate::Dictionary.new
  end

  # GET /key_indicate/dictionaries/1/edit
  def edit
  end

  # POST /key_indicate/dictionaries
  # POST /key_indicate/dictionaries.json
  def create
    @key_indicate_dictionary = KeyIndicate::Dictionary.new(key_indicate_dictionary_params)

    respond_to do |format|
      if @key_indicate_dictionary.save
        format.html { redirect_to @key_indicate_dictionary, notice: 'Dictionary was successfully created.' }
        format.json { render :show, status: :created, location: @key_indicate_dictionary }
      else
        format.html { render :new }
        format.json { render json: @key_indicate_dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /key_indicate/dictionaries/1
  # PATCH/PUT /key_indicate/dictionaries/1.json
  def update
    params[:dictionary].each{|key, value|
      indicator = KeyIndicate::DictionaryKey.find(key)
      value.each{|k,v|
        indicator[k] = v;
      }
      indicator.save
    }

    if @key_indicate_dictionary.update
      respond_to do |format|
        format.html { redirect_to key_indicate_dictionaries_path, notice: 'Dictionary was successfully updated.' }
        format.js { }
      end
    end
  end

  # DELETE /key_indicate/dictionaries/1
  # DELETE /key_indicate/dictionaries/1.json
  def destroy
    @key_indicate_dictionary.destroy
    respond_to do |format|
      format.html { redirect_to key_indicate_dictionaries_url, notice: 'Dictionary was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def dictionary_file_create
    @dictionary_files = []

    params['dictionary_file'].each do |f|
      doc = KeyIndicate::DictionaryFile.new
      doc.dictionary_file = f
      params[:key_indicate_dictionary_files][:title].blank? ? doc.title = f.original_filename : doc.title = params[:key_indicate_dictionary_files][:title]
      doc.description = params[:key_indicate_dictionary_files][:description]
      doc.key_indicate_dictionary = @key_indicate_dictionary
      doc.author = current_user.email
      doc.save
      @dictionary_files << doc

      table = read_table_from_file 'public/uploads/key_indicate/dictionary_file/dictionary_file/' + doc._id.to_s + '/' + doc.dictionary_file.filename
      doc.import table
    end unless params['dictionary_file'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
    end
  end

  def dictionary_file_update
    dictionary_file = KeyIndicate::DictionaryFile.find(params[:dictionary_file_id])
    dictionary_file.title = params[:key_indicate_dictionary_file][:title]
    dictionary_file.description = params[:key_indicate_dictionary_file][:description]
    respond_to do |format|
      if dictionary_file.update
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @key_indicate_dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  def dictionary_file_destroy
    dictionary_file = KeyIndicate::DictionaryFile.find(params[:dictionary_file_id])
    dictionary_file.destroy
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
    def set_key_indicate_dictionary
      @key_indicate_dictionary = KeyIndicate::Dictionary.first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_indicate_dictionary_params
      params.require(:key_indicate_dictionary).permit(:title, :dictionary_file_id, :description)
    end
end
