class TownsController < ApplicationController
  before_action :set_town, only: [:show, :edit, :update, :destroy]

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

  def search_for_towns
    @towns = use_cache get_controller_action_key do
      Town.all.reject{|town| town.level == 1 }
    end

    respond_to do |format|
      q = params[:query].mb_chars.capitalize.to_s
      @towns = @towns.select{ |t| Regexp.new("^#{q}.*") =~ t.title }
      format.json
    end

  end

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

  # GET /indicator_files
  # GET /indicator_files.json
  def index
    # @towns = Town.to_tree
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

  # GET /indicator_files/1/edit
  def edit
  end

  # POST /indicator_files
  # POST /indicator_files.json
  def create
    @town = Town.new(town_params)

    respond_to do |format|
      if @town.save
        format.html { redirect_to @town, notice: 'Town was successfully created.' }
        format.json { render :show, status: :created, location: @town }
      else
        format.html { render :new }
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
    @town.destroy
    respond_to do |format|
      format.html { redirect_to towns_url, notice: 'Town was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def indicator_file_destroy
    # code here
  end

  def edit_by_xls
    table = get_arr_by_table_path(params[:xls])
    errors_arr = Town.edit_counters_by_table(table)
    if errors_arr.empty?
      redirect_to :back, notice: I18n.t('xls.done')
    else
      redirect_to :back, alert: errors_arr
    end

  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_town
      @town = Town.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def town_params
      params.require(:town).permit(:title, :img, :links, :coordinates, :geometry_type, :description,
                                   :counters => [:citizens, :house_holdings, :square])
    end


end
