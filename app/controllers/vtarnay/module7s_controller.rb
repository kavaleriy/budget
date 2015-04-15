class Vtarnay::Module7sController < ApplicationController
  layout 'application_vtarnay'

  before_action :set_vtarnay_module7, only: [:show, :edit, :update, :destroy]

  # GET /vtarnay/module7s
  # GET /vtarnay/module7s.json
  def index
    @vtarnay_module7s = Vtarnay::Module7.all
  end

  # GET /vtarnay/module7s/1
  # GET /vtarnay/module7s/1.json
  def show
  end

  # GET /vtarnay/module7s/new
  def new
    @vtarnay_module7 = Vtarnay::Module7.new
  end

  # GET /vtarnay/module7s/1/edit
  def edit
  end

  # POST /vtarnay/module7s
  # POST /vtarnay/module7s.json
  def create
    @vtarnay_module7 = Vtarnay::Module7.new(vtarnay_module7_params)

    respond_to do |format|
      if @vtarnay_module7.save
        format.html { redirect_to @vtarnay_module7, notice: 'Module7 was successfully created.' }
        format.json { render :show, status: :created, location: @vtarnay_module7 }
      else
        format.html { render :new }
        format.json { render json: @vtarnay_module7.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vtarnay/module7s/1
  # PATCH/PUT /vtarnay/module7s/1.json
  def update
    respond_to do |format|
      if @vtarnay_module7.update(vtarnay_module7_params)
        format.html { redirect_to @vtarnay_module7, notice: 'Module7 was successfully updated.' }
        format.json { render :show, status: :ok, location: @vtarnay_module7 }
      else
        format.html { render :edit }
        format.json { render json: @vtarnay_module7.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vtarnay/module7s/1
  # DELETE /vtarnay/module7s/1.json
  def destroy
    @vtarnay_module7.destroy
    respond_to do |format|
      format.html { redirect_to vtarnay_module7s_url, notice: 'Module7 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vtarnay_module7
      @vtarnay_module7 = Vtarnay::Module7.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vtarnay_module7_params
      params[:vtarnay_module7]
    end
end
