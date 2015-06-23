class Programs::TargetProgramsController < ApplicationController
  before_action :set_programs_target_program, only: [:show, :edit, :update, :destroy, :attachment_destroy]
  before_action :set_town, only: [:list, :change_list, :show, :load_expences, :load_indicators]

  before_action :authenticate_user!, only: [:new, :edit, :load, :load_expences, :load_indicators]
  load_and_authorize_resource

  # GET /programs/target_programs
  # GET /programs/target_programs.json
  def index
    @programs_target_programs = Programs::TargetProgram.all
  end

  # GET /programs/target_programs/1
  # GET /programs/target_programs/1.json
  def show
    @subprograms = {}
    if @programs_target_program.kpkv[6] == "0"   # means that it its main program
      key = @programs_target_program.kpkv[0,6]
      @subprograms = Programs::TargetProgram.where(:kpkv => /#{key}[1-9]/, :programs_town_id => @programs_target_program.programs_town_id)  # get only subprograms
    end
    @amounts = {}
    @subprograms.each{|program|
      @amounts[program.id.to_s] = program.get_total_amount Time.now.year
    }
    @indicators = @programs_target_program.get_indicators
  end

  # GET /programs/target_programs/new
  def new
    @programs_target_program = Programs::TargetProgram.new
    @programs_town = Programs::Town.new
    @programs_town.generate_explanation
  end

  # GET /programs/load
  def load
  end

  def load_expences

  end

  def load_indicators

  end

  # GET /programs/target_programs
  def list
    @year = Time.now.year
    @programs_target_programs = @programs_town.programs_target_programs.where(:term_start.lte => @year, :term_end.gte => @year, :kpkv => /0$/) # get only main programs
    @amounts = {}
    @programs_target_programs.each{|program|
      @amounts[program.id.to_s] = program.get_total_amount @year
    }
  end

  def change_list
    @year = params[:year].to_i
    @programs_target_programs = @programs_town.programs_target_programs.where(:term_start.lte => @year, :term_end.gte => @year, :kpkv => /0$/) # get only main programs
    @amounts = {}
    @programs_target_programs.each{|program|
      @amounts[program.id.to_s] = program.get_total_amount @year
    }
    respond_to do |format|
      format.js
    end
  end

  # GET /programs/target_programs/1/edit
  def edit
  end

  # POST /programs/target_programs
  # POST /programs/target_programs.json
  def create
    town = Programs::Town.where( :name => (params[:town] || current_user.town) ).first
    if town.nil?
      town = Programs::Town.new
      town.name = params[:town] || current_user.town
      town.generate_explanation
      town.save
    end

    file_path = upload_file params[:path], town.id

    table = read_table_from_file file_path.to_s

    import table, town

    redirect_to action: 'list', town: town.id
  end

  # PATCH/PUT /programs/target_programs/1
  # PATCH/PUT /programs/target_programs/1.json
  def update
    respond_to do |format|
      if @programs_target_program.update params
        format.html { redirect_to @programs_target_program, notice: 'Target program was successfully updated.' }
        format.json { render :show, status: :ok, location: @programs_target_program }
      else
        format.html { render :edit }
        format.json { render json: @programs_target_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /programs/target_programs/1
  # DELETE /programs/target_programs/1.json
  def destroy
    @programs_target_program.destroy
    respond_to do |format|
      format.html { redirect_to action: 'list', town: @programs_target_program.programs_town_id }
      format.json { head :no_content }
    end
  end

  def attachment_destroy
    file = Programs::Attachment.find(params[:attachment_id])
    file.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content, status: :deleted }
    end
  end

  protected

  def upload_file uploaded_io, town_id

    file_name = uploaded_io.original_filename
    Dir.mkdir('public/') unless File.exists?('public/')
    Dir.mkdir('public/files/') unless File.exists?('public/files/')
    Dir.mkdir('public/files/target_programs/') unless File.exists?('public/files/target_programs/')
    Dir.mkdir('public/files/target_programs/' + town_id) unless File.exists?('public/files/target_programs/' + town_id)
    file_path = Rails.root.join('public', 'files', 'target_programs', town_id, file_name)

    File.open(file_path, 'wb') do |file|
      file.write(uploaded_io.read)
    end

    file_path
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

  def import table, town
    table[:rows].each { |row|
      program = Programs::TargetProgram.new
      program.author = current_user.email
      program.programs_town = town
      program.import row
      program.save
    }

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_programs_target_program
      @programs_target_program = Programs::TargetProgram.find(params[:id])
    end

    def set_town
      if params[:town]
        @programs_town = Programs::Town.where(:id.to_s => params[:town]).first
      else
        @programs_town = @programs_target_program.programs_town
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def programs_target_program_params
      params.require(:programs_target_program).permit(:town, :path, :title, :kpkv, :kfkv, :phases, :amount_plan, :targets, :tasks, :expected_results, :participants, :attachment_id)
    end
end
