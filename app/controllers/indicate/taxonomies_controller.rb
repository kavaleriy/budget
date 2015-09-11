class Indicate::TaxonomiesController < ApplicationController
  before_action :set_indicate_taxonomy, only: [:show, :edit, :update, :destroy, :indicators, :get_indicators]

  before_action :authenticate_user!, only: [:new, :edit, :show]
  load_and_authorize_resource

  layout 'visify', only: [:indicators]

  # GET /indicate/taxonomies
  # GET /indicate/taxonomies.json
  def index
    @indicate_taxonomies = Indicate::Taxonomy.all
  end

  # GET /indicate/taxonomies/1
  # GET /indicate/taxonomies/1.json
  def show
    @indicators = @indicate_taxonomy.get_indicators
    @years = @indicators.keys.sort!.reverse!
    unless @indicate_taxonomy.town
      @indicate_taxonomy.town = ""
    end
  end

  def indicators
    @indicators = @indicate_taxonomy.get_indicators
    @current_user = current_user
  end

  def get_indicators
    @indicators = @indicate_taxonomy.get_indicators
    render :json => { 'indicators' => @indicators }
  end

  # GET /indicate/taxonomies/indicator_file
  def new
    if current_user.town
      @indicate_taxonomy = Indicate::Taxonomy.where(:town => ::Town.where(:title => current_user.town).first).first || Indicate::Taxonomy.create(:town => ::Town.where(:title => current_user.town).first)
    elsif current_user.has_role? :admin
      @indicate_taxonomy = Indicate::Taxonomy.new
      @indicate_taxonomy.town = ::Town.new(:title => "")
    end
  end

  # GET /indicate/taxonomies/1/edit
  def edit
  end

  # POST /indicate/taxonomies
  # POST /indicate/taxonomies.json
  def create
    @indicate_taxonomy = Indicate::Taxonomy.new(indicate_taxonomy_params)

    respond_to do |format|
      if @indicate_taxonomy.save
        format.html { redirect_to @indicate_taxonomy, notice: 'Taxonomy was successfully created.' }
        format.json { render :show, status: :created, location: @indicate_taxonomy }
      else
        format.html { render :new }
        format.json { render json: @indicate_taxonomy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /indicate/taxonomies/1
  # PATCH/PUT /indicate/taxonomies/1.json
  def update
    respond_to do |format|
      if @indicate_taxonomy.update(indicate_taxonomy_params)
        format.html { redirect_to @indicate_taxonomy, notice: 'Taxonomy was successfully updated.' }
        format.json { render :show, status: :ok, location: @indicate_taxonomy }
      else
        format.html { render :edit }
        format.json { render json: @indicate_taxonomy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indicate/taxonomies/1
  # DELETE /indicate/taxonomies/1.json
  def destroy
    @indicate_taxonomy.destroy
    respond_to do |format|
      format.html { redirect_to indicate_taxonomies_url, notice: 'Taxonomy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_taxonomy
    @indicate_taxonomy = Indicate::Taxonomy.where(:town => params[:town]).first || Indicate::Taxonomy.new
    render :partial => '/indicate/indicator_files/indicator_files', :locals => {:files => @indicate_taxonomy.indicate_indicator_files}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_indicate_taxonomy
      @indicate_taxonomy = Indicate::Taxonomy.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def indicate_taxonomy_params
      params[:indicate_taxonomy]
    end
end
