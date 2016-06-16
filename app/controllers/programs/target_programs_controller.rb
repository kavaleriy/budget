class Programs::TargetProgramsController < ApplicationController
  layout 'application_admin', except: [:index, :show]

  before_action :authenticate_user!, only: [:new, :edit]
  # load_and_authorize_resource

  # GET /programs/target_programs
  # GET /programs/target_programs.json


  def stub_data
    @year = Date.today.year.to_s
  end

  def index
    stub_data
    @programs = TargetedPrograms::Program.get_main_programs
  end

  def show
    stub_data
    @program = TargetedPrograms::Program.first
  end


  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def programs_target_program_params
      params.require(:programs_target_program).permit(:id)
    end
end
