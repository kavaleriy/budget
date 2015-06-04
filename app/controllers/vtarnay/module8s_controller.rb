class Vtarnay::Module8sController < ApplicationController
  layout 'application_vtarnay'

  before_action :set_vtarnay_module8, only: [:show, :edit, :update, :destroy]


  def search_addr
    @location = Geocoder.coordinates(params[:q])
    # @location = Location.near(params[:q], 15, :order => :distance).first if params[:q].present?

    respond_to do |format|
      format.js
    end
  end



  # GET /vtarnay/module8s
  # GET /vtarnay/module8s.json
  def index
    @vtarnay_module8s = Vtarnay::Module8.all
  end

  # GET /vtarnay/module8s/1
  # GET /vtarnay/module8s/1.json
  def show
  end

  # GET /vtarnay/module8s/indicator_file
  def new
    @vtarnay_module8 = Vtarnay::Module8.new
  end

  # GET /vtarnay/module8s/1/edit
  def edit
  end

  # POST /vtarnay/module8s
  # POST /vtarnay/module8s.json
  def create
    @vtarnay_module8 = Vtarnay::Module8.new(vtarnay_module8_params)

    respond_to do |format|
      if @vtarnay_module8.save
        format.html { redirect_to @vtarnay_module8, notice: 'Module8 was successfully created.' }
        format.json { render :show, status: :created, location: @vtarnay_module8 }
      else
        format.html { render :new }
        format.json { render json: @vtarnay_module8.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vtarnay/module8s/1
  # PATCH/PUT /vtarnay/module8s/1.json
  def update
    respond_to do |format|
      if @vtarnay_module8.update(vtarnay_module8_params)
        format.html { redirect_to @vtarnay_module8, notice: 'Module8 was successfully updated.' }
        format.json { render :show, status: :ok, location: @vtarnay_module8 }
      else
        format.html { render :edit }
        format.json { render json: @vtarnay_module8.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vtarnay/module8s/1
  # DELETE /vtarnay/module8s/1.json
  def destroy
    @vtarnay_module8.destroy
    respond_to do |format|
      format.html { redirect_to vtarnay_module8s_url, notice: 'Module8 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vtarnay_module8
      @vtarnay_module8 = Vtarnay::Module8.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vtarnay_module8_params
      params[:vtarnay_module8]
    end
end
