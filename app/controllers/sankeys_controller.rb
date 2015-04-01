class SankeysController < ApplicationController
  before_action :set_sankey, only: [:show, :edit, :update, :destroy]

  # GET /sankeys
  # GET /sankeys.json
  def index
    @sankeys = Sankey.all
  end

  # GET /sankeys/1
  # GET /sankeys/1.json
  def show
  end

  # GET /sankeys/new
  def new
    @sankey = Sankey.new
    @budget_files_rot = TaxonomyRot.all
    @budget_files_rov = TaxonomyRov.all
  end

  # GET /sankeys/1/edit
  def edit
    @budget_files_rot = TaxonomyRot.all
    @budget_files_rov = TaxonomyRov.all
  end

  # POST /sankeys
  # POST /sankeys.json
  def create
    @sankey = Sankey.new(sankey_params)

    respond_to do |format|
      if @sankey.save
        format.html { redirect_to @sankey, notice: 'Sankey was successfully created.' }
        format.json { render :show, status: :created, location: @sankey }
      else
        format.html { redirect_to new_sankey_path, :flash => { :error => 'Така візуалізація вже існує. Спробуйте інший набір файлів.' } }
        # format.json { render json: @sankey.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sankeys/1
  # PATCH/PUT /sankeys/1.json
  def update
    respond_to do |format|
      if @sankey.update(sankey_params)
        format.html { redirect_to @sankey, notice: 'Sankey was successfully updated.' }
        format.json { render :show, status: :ok, location: @sankey }
      else
        format.html { render :edit }
        format.json { render json: @sankey.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sankeys/1
  # DELETE /sankeys/1.json
  def destroy
    @sankey.destroy
    respond_to do |format|
      format.html { redirect_to sankeys_url, notice: 'Sankey was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_rows
    @budget_file_rot = TaxonomyRot.where(:id => sankey_params[:rot_file_id]).first
    @budget_file_rov = TaxonomyRov.where(:id => sankey_params[:rov_file_id]).first
    render json: { 'rows_rot' => @budget_file_rot.get_level("kkd_a"), 'rows_rov' => @budget_file_rov.get_level("kvk") }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sankey
      @sankey = Sankey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sankey_params
      params.permit(:rot_file_id, :rov_file_id)
    end
end
