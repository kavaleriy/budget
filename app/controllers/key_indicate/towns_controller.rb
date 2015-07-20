class KeyIndicate::TownsController < ApplicationController
  before_action :set_key_indicate_town, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!, only: [:new, :edit]
  load_and_authorize_resource

  # GET /key_indicate/towns
  # GET /key_indicate/towns.json
  def index
    @key_indicate_towns = KeyIndicate::Town.all
  end

  # GET /key_indicate/towns/1
  # GET /key_indicate/towns/1.json
  def show
  end

  # GET /key_indicate/towns/new
  def new
    @key_indicate_town = KeyIndicate::Town.new
  end

  # GET /key_indicate/towns/1/edit
  def edit
  end

  # POST /key_indicate/towns
  # POST /key_indicate/towns.json
  def create
    @key_indicate_town = KeyIndicate::Town.new(key_indicate_town_params)

    respond_to do |format|
      if @key_indicate_town.save
        format.html { redirect_to @key_indicate_town, notice: 'Town was successfully created.' }
        format.json { render :show, status: :created, location: @key_indicate_town }
      else
        format.html { render :new }
        format.json { render json: @key_indicate_town.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /key_indicate/towns/1
  # PATCH/PUT /key_indicate/towns/1.json
  def update
    respond_to do |format|
      if @key_indicate_town.update(key_indicate_town_params)
        format.html { redirect_to @key_indicate_town, notice: 'Town was successfully updated.' }
        format.json { render :show, status: :ok, location: @key_indicate_town }
      else
        format.html { render :edit }
        format.json { render json: @key_indicate_town.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /key_indicate/towns/1
  # DELETE /key_indicate/towns/1.json
  def destroy
    @key_indicate_town.destroy
    respond_to do |format|
      format.html { redirect_to key_indicate_towns_url, notice: 'Town was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def indicator_file_create
    @indicator_files = []
    if current_user.has_role? :admin
      @indicate_taxonomy = Indicate::Taxonomy.where(:town => params[:town]).first || Indicate::Taxonomy.new(:town => params[:town])
    end

    params['indicate_file'].each do |f|
      doc = Indicate::IndicatorFile.new(indicate_indicator_file_params)
      doc.indicate_file = f
      doc.indicate_taxonomy = @indicate_taxonomy
      doc.author = current_user.email
      doc.save
      @indicator_files << doc

      table = read_table_from_file 'public/uploads/indicate/indicator_file/indicate_file/' + doc._id.to_s + '/' + doc.indicate_file.filename
      doc.import table
    end unless params['indicate_file'].nil?

    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :created }
    end
  end

  def indicator_file_update
    attachment = TaxonomyAttachment.where(:id => params[:attachment_id])
    respond_to do |format|
      if attachment.update(params[:taxonomy_attachment])
        format.js {}
        format.json { head :no_content, status: :updated }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @indicate_indicator_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def indicator_file_destroy
    attachment = TaxonomyAttachment.where(:id => params[:attachment_id])
    attachment.destroy
    respond_to do |format|
      format.js {}
      format.json { head :no_content, status: :deleted }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_key_indicate_town
      @key_indicate_town = KeyIndicate::Town.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_indicate_town_params
      params.require(:key_indicate_town).permit(:title, :indicator_file_id, :description)
    end
end
