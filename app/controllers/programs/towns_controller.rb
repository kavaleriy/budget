class Programs::TownsController < ApplicationController
  before_action :set_programs_town, only: [:show, :edit, :update, :destroy]

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
    respond_to do |format|
      if @programs_town.update(programs_town_params)
        format.html { redirect_to @programs_town, notice: 'Town was successfully updated.' }
        format.json { render :show, status: :ok, location: @programs_town }
      else
        format.html { render :edit }
        format.json { render json: @programs_town.errors, status: :unprocessable_entity }
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
