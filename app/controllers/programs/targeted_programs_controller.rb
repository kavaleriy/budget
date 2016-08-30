class Programs::TargetedProgramsController < ApplicationController
  layout 'application_admin', except: [:index, :show]
  respond_to :html
  before_action :authenticate_user!, only: [:new, :edit]
  before_action :set_target_program,only: [:edit,:show,:update]
  # load_and_authorize_resource

  # GET /programs/target_programs
  # GET /programs/target_programs.json



  def index
    stub_data
    @programs = Programs::TargetedProgram.get_main_programs
  end

  def new
    @program = Programs::TargetedProgram.new
    @program.init_default_budget_sum
    stub_data
  end

  def create
    @program = Programs::TargetedProgram.new(programs_targeted_program_params)
    @program.save
    respond_with(@program)
  end

  def show
    stub_data
    @grouped_indicators = Programs::TargetedProgram.get_grouped_indicators(@program.indicators)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
  end

  def update
    @program.update(programs_targeted_program_params)
    respond_with(@program)
  end

  def import
    program = Programs::TargetedProgram.import(params[:import_file].tempfile)
    program.town = Town.get_user_town(current_user)
    if program.save
      redirect_to programs_targeted_program_path(program)
    else
      redirect_to :back, alert: 'Вибачте сталася помилка'
    end

  end

  private

  def set_target_program
    @program = Programs::TargetedProgram.find(params[:id])
  end
  def stub_data
    @year = Date.today.year.to_s
  end

  # Never trust parameters from the scary internet, only allow the white list through.
    def programs_targeted_program_params
      params.require(:programs_targeted_program).permit!
      # (:id,:responsible,:title,:p_id,:tasks => [],:budget_sum => [])
    end
end
