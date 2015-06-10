class Repairing::RepairsController < ApplicationController
  before_action :set_repairing_repair, only: [:show, :edit, :update, :destroy]

  # GET /repairing/repairs
  # GET /repairing/repairs.json
  def index
    @repairing_repairs = Repairing::Repair.all
  end

  # GET /repairing/repairs/1
  # GET /repairing/repairs/1.json
  def show
  end

  # GET /repairing/repairs/new
  def new
    @repairing_repair = Repairing::Repair.new
  end

  # GET /repairing/repairs/1/edit
  def edit
  end

  # POST /repairing/repairs
  # POST /repairing/repairs.json
  def create
    map = Repairing::Map.find(params[:map_id])
    @repairing_repair = map.repairs.new(repairing_repair_params)

    respond_to do |format|
      if @repairing_repair.save
        format.json { render :show, status: :created, location: @repairing_map_repair }
      else
        format.html { render :new }
        format.json { render json: @repairing_repair.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repairing/repairs/1
  # PATCH/PUT /repairing/repairs/1.json
  def update
    addr = Geocoder.search(repairing_repair_params[:coordinates]).first
    binding.pry

    respond_to do |format|
      if @repairing_repair.update(repairing_repair_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @repairing_repair.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repairing/repairs/1
  # DELETE /repairing/repairs/1.json
  def destroy
    @repairing_repair.destroy
    respond_to do |format|
      format.html { redirect_to repairing_repairs_url, notice: 'Repair was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repairing_repair
      @repairing_repair = Repairing::Repair.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repairing_repair_params
      params.require(:repairing_repair).permit(:title, :koatuu, :district, :street, :description, :amount, :repair_date, :coordinates => [])
    end
end
