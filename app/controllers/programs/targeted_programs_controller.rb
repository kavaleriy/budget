class Programs::TargetedProgramsController < ApplicationController
  layout 'application_admin', except: [:show]
  respond_to :html
  before_action :authenticate_user!, only: [:new, :edit]
  before_action :set_target_program, only: [:edit, :show, :update, :lock, :destroy]
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
    respond_with(@grouped_indicators) do |format|
      format.js   { render layout: false }
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
    # set town
    program.town = Town.get_user_town(current_user)
    # set autor
    program.author = current_user
    # attach upload file
    program.targeted_program_file = params[:import_file]

    respond_with(program) do |format|
      if program.save
        flash[:success] = t('targeted_programs.import.success')
        format.html { redirect_to action: 'index' }
      else
        flash[:error] = t('targeted_programs.import.error')
        format.html { redirect_to :back }
      end
    end
  end

  def destroy
    @program.destroy
    flash[:success] = t('targeted_programs.destroy.success')
    respond_to do |format|
      format.html { redirect_to action: 'index' }
      format.js   { render layout: false }
      format.json { render json: @program.errors, status: :unprocessable_entity }
    end
  end

  def lock
    if params[:action]
      @program.active = @program.active ? false : true
    end
    @program.save
    respond_with(@program) do |format|
      if @program.save
        flash[:success] = 'Updated!'
        format.js { render layout: false }
      else
        flash[:error] = 'Error!'
        format.js
      end
    end
  end


  def town_programs
    @programs = Programs::TargetedProgram.by_town(params[:town])
    @years = Programs::TargetedProgram.programs_years(@programs)

    taxonomies = TaxonomyRov.active_taxonomies_by_town(params[:town]).last

    if taxonomies.blank?
      taxonomies = TaxonomyRov.last_taxonomies_by_town(params[:town])
    end

    @tax_data = Programs::TargetedProgram.data_bar(taxonomies, @years, 'kvk')


    respond_with(@programs) do |format|
      format.js { render layout: false }
      format.html { render file: 'programs/targeted_programs/town_programs', layout: 'visify'}
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
