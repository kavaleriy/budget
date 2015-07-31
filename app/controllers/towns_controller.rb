class TownsController < ApplicationController
  before_action :set_town, only: [:show, :edit, :update, :destroy]

  def search
    respond_to do |format|
      q = params[:query].mb_chars.capitalize.to_s
      @towns = Town.where(:title => Regexp.new("^#{q}.*")).order_by(:level => :asc)
      format.json
    end
  end

  def search_for_documents
    respond_to do |format|
      q = params[:query].mb_chars.capitalize.to_s
      @towns = Town.where(:title => Regexp.new("^#{q}.*")).order_by(:level => :asc).select{ |t| !t.documentation_documents.empty? }
      format.json
    end
  end

  # GET /indicator_files
  # GET /indicator_files.json
  def index
    @towns = Town.to_tree
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
      if @town.update(town_params)
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_town
      @town = Town.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def town_params
      params.require(:town).permit(:title, :img, :links)
    end
end
