class Repairing::Map::RepairsController < ApplicationController
  before_action :set_repairing_map_repair, only: [:show, :edit, :update, :destroy]

  # GET /repairing/map/repairs
  # GET /repairing/map/repairs.json
  def index
    @repairing_map_repairs = Repairing::Map::Repair.all
  end

  # GET /repairing/map/repairs/1
  # GET /repairing/map/repairs/1.json
  def show
  end

  # GET /repairing/map/repairs/new
  def new
    @repairing_map_repair = Repairing::Map::Repair.new
  end

  # GET /repairing/map/repairs/1/edit
  def edit
  end

  # POST /repairing/map/repairs
  # POST /repairing/map/repairs.json
  def create
    @repairing_map_repair = Repairing::Map::Repair.new(repairing_map_repair_params)

    respond_to do |format|
      if @repairing_map_repair.save
        format.html { redirect_to @repairing_map_repair, notice: 'Repair was successfully created.' }
        format.json { render :show, status: :created, location: @repairing_map_repair }
      else
        format.html { render :new }
        format.json { render json: @repairing_map_repair.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repairing/map/repairs/1
  # PATCH/PUT /repairing/map/repairs/1.json
  def update
    respond_to do |format|
      if @repairing_map_repair.update(repairing_map_repair_params)
        format.html { redirect_to @repairing_map_repair, notice: 'Repair was successfully updated.' }
        format.json { render :show, status: :ok, location: @repairing_map_repair }
      else
        format.html { render :edit }
        format.json { render json: @repairing_map_repair.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repairing/map/repairs/1
  # DELETE /repairing/map/repairs/1.json
  def destroy
    @repairing_map_repair.destroy
    respond_to do |format|
      format.html { redirect_to repairing_map_repairs_url, notice: 'Repair was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repairing_map_repair
      @repairing_map_repair = Repairing::Map::Repair.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repairing_map_repair_params
      params.require(:repairing_map_repair).permit(:title, :koatuu, :district, :street, :description, :amount, :coordinates)
    end
end
