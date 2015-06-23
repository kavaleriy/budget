class Programs::TownsController < ApplicationController
  before_action :set_programs_town, only: [:show, :edit, :update, :update_custom, :destroy, :expences_file_destroy, :indicator_file_destroy, :branch_report]

  # GET /programs/towns
  # GET /programs/towns.json
  def index
    @programs_towns = Programs::Town.all
  end

  # GET /programs/towns/1
  # GET /programs/towns/1.json
  def show
  end

  # GET /programs/towns/new
  def new
    @programs_town = Programs::Town.new
  end

  def branch_report
    @report = {}
    year = Time.now.year
    @programs_town.programs_target_programs.each{|program|
      kfkv = program['kfkv']
      amounts = program.get_total_amount year
      @report[kfkv] = {} if @report[kfkv].nil?
      @report[kfkv]['name'] = @programs_town.explanation['kfkv'][kfkv]['description'] if @report[kfkv]['name'].nil?
      @report[kfkv]['count'] = 0 if @report[kfkv]['count'].nil?
      @report[kfkv]['count'] += 1
      @report[kfkv]['plan'] = 0 if @report[kfkv]['plan'].nil?
      @report[kfkv]['plan'] += amounts['amount_plan']
      @report[kfkv]['fact'] = 0 if @report[kfkv]['fact'].nil?
      @report[kfkv]['fact'] += amounts['amount_fact']
      @report[kfkv]['history'] = {} if @report[kfkv]['history'].nil?
      program.programs_expences.each{|expence|
        curr_year = expence['year']
        @report[kfkv]['history'][curr_year] = {} if @report[kfkv]['history'][curr_year].nil?
        @report[kfkv]['history'][curr_year]['plan'] = 0 if @report[kfkv]['history'][curr_year]['plan'].nil?
        @report[kfkv]['history'][curr_year]['plan'] += expence['amount_plan']
        @report[kfkv]['history'][curr_year]['fact'] = 0 if @report[kfkv]['history'][curr_year]['fact'].nil?
        @report[kfkv]['history'][curr_year]['fact'] += expence['amount_fact']
      }
    }
  end

  # GET /programs/towns/1/edit
  def edit
  end

  # POST /programs/towns
  # POST /programs/towns.json
  def create
    @programs_town = Programs::Town.new(programs_town_params)

    respond_to do |format|
      if @programs_town.save
        format.html { redirect_to @programs_town, notice: 'Town was successfully created.' }
        format.json { render :show, status: :created, location: @programs_town }
      else
        format.html { render :new }
        format.json { render json: @programs_town.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /programs/towns/1
  # PATCH/PUT /programs/towns/1.json
  def update
    @programs_town.explanation = params[:explanation]
    @programs_town.save
    respond_to do |format|
      if @programs_town.update(programs_town_params)
        format.html { redirect_to '/programs/target_programs/list/' + @programs_town.id, notice: t('programs.towns.edit.notice') }
        format.json { render :show, status: :ok, location: @programs_town }
      else
        format.html { render :edit }
        format.json { render json: @programs_town.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_custom
    key = params[:explanation].keys.first
    code = params[:explanation][key].keys.first
    description = params[:explanation][key][code]['comment']
    @programs_town.explanation[key][code] = {} if key == 'sub_kvkv'
    @programs_town.explanation[key][code]['description'] = description

    if @programs_town.save
      respond_to do |format|
        format.js {}
        format.json { head :no_content, status: :updated }
      end
    end
  end

  # DELETE /programs/towns/1
  # DELETE /programs/towns/1.json
  def destroy
    @programs_town.destroy
    respond_to do |format|
      format.html { redirect_to programs_towns_url, notice: 'Town was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def expences_file_destroy
    file = Programs::ExpencesFile.find(params[:expences_file_id])
    file.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content, status: :deleted }
    end
  end

  def indicator_file_destroy
    file = Programs::IndicatorFile.find(params[:indicator_file_id])
    file.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content, status: :deleted }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_programs_town
      @programs_town = Programs::Town.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def programs_town_params
      params[:programs_town]
    end
end
