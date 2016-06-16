class Programs::TargetProgramsController < ApplicationController
  layout 'application_admin', except: [:index, :show]
  respond_to :html
  before_action :authenticate_user!, only: [:new, :edit]
  before_action :set_target_program,only: [:edit,:show,:update]
  # load_and_authorize_resource

  # GET /programs/target_programs
  # GET /programs/target_programs.json



  def index
    stub_data
    @programs = Programs::TargetProgram.get_main_programs
  end

  def new
    @main_programs = Programs::TargetProgram.get_main_programs
    @program = Programs::TargetProgram.new
  end

  def create
    @program = Programs::TargetProgram.new(programs_target_program_params)
    @program.save
    respond_with(@program)
  end

  def show
    stub_data
    # @program = Programs::TargetProgram.first
  end

  def edit
  end

  def update
    @program.update(programs_target_program_params)
    respond_with(@program)
  end



  private

  def set_target_program
    @program = Programs::TargetProgram.find(params[:id])
  end
  def stub_data
    @year = Date.today.year.to_s
  end

  # Never trust parameters from the scary internet, only allow the white list through.
    def programs_target_program_params
      params.require(:programs_target_program).permit(:id,:responsible,:title,:p_id,:description)
    end
end
