class SankeysController < ApplicationController
  before_action :set_sankey, only: [:show, :sankey, :edit, :update, :destroy]
  after_action :allow_iframe, only: [:sankey]
  layout 'visify', only: [:sankey]

  before_action :authenticate_user!, only: [:new, :edit]
  # before_action :authenticate_user!, only: [:index, :indicator_file, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /sankeys
  # GET /sankeys.json
  def index
    @sankeys = Sankey.all
  end

  # GET /sankeys/1
  # GET /sankeys/1.json
  def show
  end

  def sankey
  end

  # GET /sankeys/indicator_file
  def new
    @sankey = Sankey.new
    if current_user.has_role? :admin
      @budget_files_rot = TaxonomyRot.all
      @budget_files_rov = TaxonomyRov.all
    else
      @budget_files_rot = TaxonomyRot.all.where(:owner => current_user.town)
      @budget_files_rov = TaxonomyRov.all.where(:owner => current_user.town)
    end
  end

  # GET /sankeys/1/edit
  def edit
    @budget_files_rot = TaxonomyRot.all.where(:owner => @sankey.owner)
    @budget_files_rov = TaxonomyRov.all.where(:owner => @sankey.owner)
  end

  # POST /sankeys
  # POST /sankeys.json
  def create
    @sankey = Sankey.new(sankey_params)
    @sankey.owner = current_user.town

    respond_to do |format|
      if @sankey.save
        format.html { redirect_to @sankey, notice: t('budget_files_controller.save') }
        format.json { render :show, status: :created, location: @sankey }
      else
        format.html { redirect_to new_sankey_path, :flash => { :error => t('sankeys.save_fail') } }
        # format.json { render json: @sankey.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sankeys/1
  # PATCH/PUT /sankeys/1.json
  def update
    respond_to do |format|
      if @sankey.update(sankey_params)
        format.html { redirect_to @sankey, notice: t('budget_files_controller.save') }
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
      format.html { redirect_to sankeys_url, notice: t('budget_files_controller.delete') }
      format.json { head :no_content }
    end
  end

  def get_rows
    @budget_file_rot = TaxonomyRot.where(:id => sankey_params[:rot_file_id]).first
    @budget_file_rov = TaxonomyRov.where(:id => sankey_params[:rov_file_id]).first
    render json: { 'rows_rot' => @budget_file_rot.get_level_with_fonds("kkd_a"), 'rows_rov' => @budget_file_rov.get_level_with_fonds("ktfk_aaa") }
  end

  def town_profile
    if params[:town_id] == 'test'
      @sankey = Sankey.where(:owner => '').first
    else
      town = Town.find(params[:town_id])
      @sankey = Sankey.where(:owner => town.title).first
    end
    render 'show'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sankey
      @sankey = Sankey.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sankey_params
      params.permit(:rot_file_id, :rov_file_id, :title)
    end

    def allow_iframe
      response.headers['x-frame-options'] = 'ALLOWALL'
    end
end
