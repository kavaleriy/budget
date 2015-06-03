class Vtarnay::Module5sController < ApplicationController
  before_action :set_vtarnay_module5, only: [:destroy]
  before_action :set_user_town, only: [:new, :edit, :update, :create, :download]
  before_action :authenticate_user!
  # load_and_authorize_resource

  # GET /vtarnay/module5s
  # GET /vtarnay/module5s.json
  def index
    towns = Vtarnay::Module5.pluck(:town)
    @towns = {}
    towns.each {|town|
      if @towns[town].nil?
        @towns[town] = town
      end
    }
  end

  # GET /vtarnay/module5s/1
  # GET /vtarnay/module5s/1.json
  def show
    @town = params[:id]
    @vtarnay_module5s = Vtarnay::Module5.all.where(:town => @town)
    @rows = {}
    @vtarnay_module5s.each{|file|
      file['rows'].each {|row|
        row.each{|data|
          if data['value']
            group = data['group']
            if @rows[group].nil?
              @rows[group] = {}
            end
            indicator = data['indicator']
            if @rows[group][indicator].nil?
              @rows[group][indicator] = {}
            end
            year = data['year'].to_i
            @rows[group][indicator][year] = {}
            @rows[group][indicator][year]['comment'] = data['comment']
            @rows[group][indicator][year]['value'] = data['value']
          end
        }
      }
    }
  end

  # GET /vtarnay/module5s/indicator_file
  def new
    @vtarnay_module5 = Vtarnay::Module5.new
    @vtarnay_module5s = Vtarnay::Module5.all.where(:town => @town)
  end

  # GET /vtarnay/module5s/1/edit
  def edit
    @vtarnay_module5s = Vtarnay::Module5.all.where(:town => @town)
    @rows = {}
    @vtarnay_module5s.each{|file|
      file['rows'].each_with_index {|row, index|
        row.each{|data|
          if data['value']
            year = data['year'].to_i
            if @rows[year].nil?
              @rows[year] = {}
            end
            group = data['group']
            if @rows[year][group].nil?
              @rows[year][group] = {}
            end
            indicator = data['indicator']
            if @rows[year][group][indicator].nil?
              @rows[year][group][indicator] = {}
            end
            @rows[year][group][indicator]['comment'] = data['comment']
            @rows[year][group][indicator]['file_id'] = file['_id'].to_s
            @rows[year][group][indicator]['row_index'] = index
          end
        }
      }
    }
    @years = @rows.keys.sort!.reverse!
  end

  # POST /vtarnay/module5s
  # POST /vtarnay/module5s.json
  def create
    @vtarnay_module5 = Vtarnay::Module5.new(vtarnay_module5_params)

    @vtarnay_module5.author = current_user.email unless current_user.nil?
    @vtarnay_module5.town = @town

    file = upload_file vtarnay_module5_params[:path]
    file_name = file[:name]
    file_path = file[:path].to_s

    @vtarnay_module5.path = file_path

    @vtarnay_module5.title = vtarnay_module5_params[:title].empty? ? "#{file_name} - #{DateTime.now.strftime('%d-%m-%Y')}" : vtarnay_module5_params[:title]

    table = read_table_from_file file_path

    @vtarnay_module5.import table

    respond_to do |format|
      if @vtarnay_module5.save
        flash[:notice] = t('budget_files_controller.load_success')
        format.html { redirect_to action: 'show', id: @vtarnay_module5.town}
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
    params['array'].each{|file_id, value|
      file = Vtarnay::Module5.where(:id => file_id).first
      value.each{|row_index, row_value|
        row_value.each{|column, val|
          file.rows[row_index][column] = val
        }
      }
      if !file.save
        respond_to do |format|
          format.html { render :edit }
          format.json { render json: @vtarnay_module5.errors, status: :unprocessable_entity }
        end
      end
    }
    respond_to do |format|
      flash[:notice] = t('budget_files_controller.load_success')
      format.html { redirect_to action: 'show', id: @town}
      format.json { render :show, status: :created, location: @town }
    end
  end

  # DELETE /vtarnay/module5s/1
  # DELETE /vtarnay/module5s/1.json
  def destroy
    @vtarnay_module5.destroy
    respond_to do |format|
      format.html { redirect_to new_vtarnay_module5_path, notice: t('budget_files_controller.delete') }
      format.json { head :no_content }
    end
  end

  def download
    require 'rubygems'
    require 'zip'

    town = params[:id]
    folder = 'public/files/indicators/' + town
    files = Vtarnay::Module5.all.where(:town => town)

    zipfile_name = 'public/files/indicators/' + town + '/archive.zip'
    temp_file = Tempfile.new('archive.zip')

    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
      files.each do |file|
        file_path = file.path.split('/')
        file_name = file_path[file_path.length-1]
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(file_name, folder + '/' + file_name)
      end
    end
    zip_data = File.read(temp_file.path)
    send_data(zip_data, :type => 'application/zip', :filename => 'archive.zip')

  end

  protected
  def upload_file attachment
    file_name = attachment.original_filename
    Dir.mkdir('public/files/indicators/') unless File.exists?('public/files/indicators/')
    Dir.mkdir('public/files/indicators/' + @town) unless File.exists?('public/files/indicators/' + @town)
    file_path = Rails.root.join('public', 'files', 'indicators', @town, file_name)
    File.open(file_path, 'wb') do |file|
      file.write(attachment.read)
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

    def set_user_town
      @town = current_user.town unless current_user.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vtarnay_module5_params
      params.require(:vtarnay_module5).permit(:title, :path)
    end
end
