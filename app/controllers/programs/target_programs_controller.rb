class Programs::TargetProgramsController < ApplicationController
  before_action :set_programs_target_program, only: [:show, :edit, :update, :destroy]

  # GET /programs/target_programs
  # GET /programs/target_programs.json
  def index
    @programs_target_programs = Programs::TargetProgram.all
  end

  # GET /programs/target_programs/1
  # GET /programs/target_programs/1.json
  def show
  end

  # GET /programs/target_programs/new
  def new
    @programs_target_program = Programs::TargetProgram.new
  end

  # GET /programs/target_programs/1/edit
  def edit
  end

  # POST /programs/target_programs
  # POST /programs/target_programs.json
  def create
    @programs_target_program = Programs::TargetProgram.new(programs_target_program_params)

    respond_to do |format|
      if @programs_target_program.save
        format.html { redirect_to @programs_target_program, notice: 'Target program was successfully created.' }
        format.json { render :show, status: :created, location: @programs_target_program }
      else
        format.html { render :new }
        format.json { render json: @programs_target_program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /programs/target_programs/1
  # PATCH/PUT /programs/target_programs/1.json
  def update
    respond_to do |format|
      if @programs_target_program.update(programs_target_program_params)
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
      format.html { redirect_to programs_target_programs_url, notice: 'Target program was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_programs_target_program
      @programs_target_program = Programs::TargetProgram.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def programs_target_program_params
      params[:programs_target_program]
    end
end
