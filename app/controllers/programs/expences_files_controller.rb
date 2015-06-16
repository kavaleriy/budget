class Programs::ExpencesFilesController < ApplicationController
  before_action :set_programs_expences_file, only: [:show, :edit, :update, :destroy]
  before_action :set_programs_target_program, only: [:destroy]

  # GET /programs/expences_files
  # GET /programs/expences_files.json
  def index
    @programs_expences_files = Programs::ExpencesFile.all
  end

  # GET /programs/expences_files/1
  # GET /programs/expences_files/1.json
  def show
  end

  # GET /programs/expences_files/new
  def new
    @programs_expences_file = Programs::ExpencesFile.new
  end

  # GET /programs/expences_files/1/edit
  def edit
  end

  # POST /programs/expences_files
  # POST /programs/expences_files.json
  def create

    @expences_files = []
    @programs_target_program = Programs::TargetProgram.where(:id => params[:programs_expences_file][:programs_target_program_id]).first

    params['expences_file'].each do |f|
      doc = Programs::ExpencesFile.new(programs_expences_file_params)
      doc.expences_file = f
      doc.programs_target_program = @programs_target_program
      doc.author = current_user.email
      doc.save
      @expences_files << doc

      # table = read_table_from_file 'public/uploads/programs/expences_file/expences_file/' + doc._id.to_s + '/' + doc.programs_expences_file.filename
      # doc.import table
    end unless params['expences_file'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
    end

  end

  # PATCH/PUT /programs/expences_files/1
  # PATCH/PUT /programs/expences_files/1.json
  def update
    respond_to do |format|
      if @programs_expences_file.update(programs_expences_file_params)
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @programs_expences_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /programs/expences_files/1
  # DELETE /programs/expences_files/1.json
  def destroy
    @programs_expences_file.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content, status: :deleted }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_programs_expences_file
      @programs_expences_file = Programs::ExpencesFile.find(params[:id])
    end

    def set_programs_target_program
      @programs_target_program = @programs_expences_file.programs_target_program
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def programs_expences_file_params
      params.require(:programs_expences_file).permit(:programs_target_program_id, :title, :description)
    end
end
