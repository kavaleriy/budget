class Indicate::TaxonomiesController < ApplicationController
  layout 'application_admin'
  before_action :set_indicate_taxonomy, only: [:show, :edit, :update, :destroy, :indicators, :get_indicators]
  before_action :create_indicate_taxonomy, only: [:new]

  before_action :authenticate_user!, except: [:get_indicators, :indicators, :town_profile]
  load_and_authorize_resource

  skip_before_filter :verify_authenticity_token, only: [:get_indicators]
  after_filter :allow_iframe, only: [:indicators]

  # GET /indicate/taxonomies
  # GET /indicate/taxonomies.json
  def index
    @indicate_taxonomies = Indicate::Taxonomy.all
    @indicate_taxonomies = @indicate_taxonomies.by_towns(params['town_select'])   unless params['town_select'].blank?
  end

  # GET /indicate/taxonomies/1
  # GET /indicate/taxonomies/1.json
  def show
    @indicators = @indicate_taxonomy.get_indicators
    @years = @indicators.keys.sort!.reverse!
  end

  def indicators
    @indicators = @indicate_taxonomy.get_indicators
    @current_user = current_user
    render layout: 'visify'
  end

  def get_indicators
    @indicators = @indicate_taxonomy.get_indicators
    render json: { indicators: @indicators }
  end

  # GET /indicate/taxonomies/indicator_file
  def new
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
    @indicate_taxonomy = Indicate::Taxonomy.by_town(params[:town]).first || Indicate::Taxonomy.new
    render partial: '/indicate/indicator_files/indicator_files', locals: {files: @indicate_taxonomy.indicate_indicator_files}
  end

  def town_profile
    @indicate_taxonomy = Indicate::Taxonomy.by_town(params[:town_id]).first

    @indicators = @indicate_taxonomy.get_indicators
    @years = @indicators.keys.sort!.reverse!
    @current_user = current_user || User.new(town: Town.get_test_town.first)
    respond_to do |format|
      format.html {render 'show'}
      format.js { render 'show'}
    end

  end

  private
  # Copy from WidgetsController for show iframe in other sites
  def allow_iframe
    response.headers['x-frame-options'] = 'ALLOWALL'
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_indicate_taxonomy
    @indicate_taxonomy = Indicate::Taxonomy.find(params[:id])
  end

  def get_town_by_user
    Town.find(current_user.town_model)
  end

  def create_indicate_taxonomy
    @indicate_taxonomy = Indicate::Taxonomy.by_town(get_town_by_user).first || Indicate::Taxonomy.new(town: get_town_by_user)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def indicate_taxonomy_params
    params[:indicate_taxonomy]
  end
end
