class TownsController < ApplicationController
  before_action :set_town, only: [:show, :edit, :update, :destroy, :export_town_in_xls]
  before_action :access_user, only: [:index, :show, :edit, :update, :destroy]

  include ControllerCaching
  include BudgetFileUpload

  def search
    respond_to do |format|
      q = params[:query].mb_chars.capitalize.to_s
      @towns = Town.where(:title => Regexp.new("^#{q}.*")).order_by(:level => :asc)
      format.json
    end
  end

  def search_for_documents
    @towns = use_cache get_controller_action_key do
      Town.all.reject{|town| town.documentation_documents.empty?}
    end

    respond_to do |format|
      q = params[:query].mb_chars.capitalize.to_s
      @towns = @towns.select{ |t| Regexp.new("^#{q}.*") =~ t.title }
      format.json
    end
  end

  # Method doesn't use
  # see at routes search_for_areas_town
  # WARN! maybe use it in ajax
  def search_for_towns_and_areas
    @towns = use_cache get_controller_action_key do
      Town.all.reject{|town| town.level != 13 && town.level != 1 }
    end

    respond_to do |format|
      q = params[:query].mb_chars.capitalize.to_s
      @towns = @towns.select{ |t| Regexp.new("^#{q}.*") =~ t.title }
      format.json
    end

  end

  def search_for_regions
    @towns = use_cache get_controller_action_key do
      Town.all.reject{|town| town.level != 2 }
    end

    respond_to do |format|
      q = params[:query].mb_chars.capitalize.to_s
      @towns = @towns.select{ |t| Regexp.new("^#{q}.*") =~ t.title }
      format.json
    end

  end

  def search_for_towns
    @towns = use_cache get_controller_action_key do
      # Town.all.reject{|town| town.level == 1 }
      Town.all
    end

    respond_to do |format|
      q = params[:query].mb_chars.capitalize.to_s
      @towns = @towns.select{ |t| Regexp.new("^#{q}.*") =~ t.title }
      format.json
    end

  end

  # Method doesn't use
  # see at routes search_for_areas_town
  # WARN! maybe use it in ajax
  def search_for_areas
    @towns = use_cache get_controller_action_key do
      Town.all.reject{|town| town.level != 1 }
    end

    respond_to do |format|
      q = params[:query].mb_chars.capitalize.to_s
      @towns = @towns.select{ |t| Regexp.new("^#{q}.*") =~ t.title }
      format.json
    end

  end

  # Method for find towns at town profile
  def search_for_active_towns
    q = params[:query].mb_chars.capitalize.to_s
    @towns  = Town.get_central_authority_towns(q).order_by(:level => :asc)
    respond_to do |format|
      format.json { render 'search'}
    end
  end

  # GET /indicator_files
  # GET /indicator_files.json
  def index
    @test_town = Town.get_test_town.first
    @towns = Town.areas
  end

  # GET /indicator_files/1
  # GET /indicator_files/1.json
  def show
  end

  # GET /indicator_files/indicator_file
  def new
    @town = Town.new
  end

  def new_town
    @town = Town.new
    @levels = Town.get_levels_array
  end
  # GET /indicator_files/1/edit
  def edit
  end

  # POST /indicator_files
  # POST /indicator_files.json
  def create
    @town = Town.new(town_params)
    respond_to do |format|

    @town.area_title = Town.get_area_title(town_params[:koatuu])
      if  @town.save
        format.html { redirect_to @town, notice: 'Town was successfully created.' }
        format.json { render :show, status: :created, location: @town }
      else
        format.html { render :new_town }
        format.json { render json: @town.errors, status: :unprocessable_entity }
      end
    end
  end



  # PATCH/PUT /indicator_files/1
  # PATCH/PUT /indicator_files/1.json
  def update
    respond_to do |format|
      attrs = town_params
      attrs.delete(:coordinates)
      coordinates = eval(town_params[:coordinates] || '')

      if @town.update_attributes(attrs)
        @town.update(coordinates: coordinates)
        format.html { redirect_to @town, notice: 'Town was successfully updated.' }
        format.json { render :show, status: :ok, location: @town }
      else
        format.html { render :edit }
        format.json { render json: @town.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indicator_files/1
  # DELETE /indicator_files/1.json
  def destroy
    if current_user.admin?
      @town.destroy
      respond_to do |format|
        format.html { redirect_to towns_url, notice: 'Town was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  def indicator_file_destroy
    # code here
  end

  def edit_by_xls
    begin
      errors_arr = []
      table = get_arr_by_table_path(params[:xls])
      errors_arr = Town.edit_nested_by_table(table, params[:nested])
    rescue Mongoid::Errors::UnknownAttribute => detail
      errors_arr << I18n.t('xls.check_row_name')
    end

    if errors_arr.empty?
      redirect_to :back, notice: I18n.t('xls.done')
    else
      redirect_to :back, alert: errors_arr
    end
  end

  def export_town_in_xls
    require 'xls_worker'
    @res_table =  XlsWorker.create_xls_by_town(@town)
    respond_to do |format|
      format.xls { send_data @res_table }
    end

  end

  def get_parent
    @parent = Town.has_parents(params[:level], params[:koatuu])
  end

  def get_child_regions
    @koatuu = params[:koatuu]
    area_code = params[:koatuu].slice(0,2)
    @town = Town.cities(area_code)
    @regions = Town.regions(area_code).to_a
  end

  def get_child_towns
    @koatuu = params[:koatuu]
    area_code = params[:koatuu].slice(0,5)
    region = Town.get_town_by_koatuu(@koatuu).first
    region_town = Town.region_towns(region.id)
    region_cities = Town.towns(area_code)

    @cities = region_town + region_cities
  end

  private

  def access_user
    return if current_user && current_user.has_any_role?(:admin, :city_authority, :central_authority)
    redirect_to root_url, alert: t('export_budgets.notice_access')
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_town
    @town = Town.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def town_params
    params.require(:town).permit(
      :region_title,
      :area_town,
      :level,
      :koatuu,
      :title,
      :img,
      :links,
      :coordinates,
      :geometry_type,
      :description,
      :permit_emails,
      :auto_send_appeal,
      counters: [:citizens, :house_holdings, :square],
      emails_attributes: [:id, :email, :owner, :_destroy]
    )
  end

end
