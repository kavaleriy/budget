class Programs::IndicatorFilesController < ApplicationController
  before_action :set_programs_indicator_file, only: [:show, :edit, :update, :destroy]
  before_action :set_programs_target_program, only: [:destroy]

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
    @programs_target_program = Programs::TargetProgram.where(:id => params[:programs_indicator_file][:programs_target_program_id]).first

    params['indicator_file'].each do |f|
      doc = Programs::IndicatorFile.new(programs_indicator_file_params)
      doc.indicator_file = f
      doc.programs_target_program = @programs_target_program
      doc.author = current_user.email
      doc.save
      @indicator_files << doc

      # table = read_table_from_file 'public/uploads/programs/programs_indicator_file/programs_indicator_file/' + doc._id.to_s + '/' + doc.programs_indicator_file.filename
      # doc.import table
    end unless params['indicator_file'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_programs_indicator_file
      @programs_indicator_file = Programs::IndicatorFile.find(params[:id])
    end

    def set_programs_target_program
      @programs_target_program = @programs_indicator_file.programs_target_program
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def programs_indicator_file_params
      params.require(:programs_indicator_file).permit(:programs_target_program_id, :title, :description)
    end
end
