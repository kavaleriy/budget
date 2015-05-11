class Document::CategoriesController < ApplicationController
  before_action :set_document_category, only: [:show, :edit, :update, :destroy]

  # GET /document/categories
  # GET /document/categories.json
  def index
    @document_categories = Document::Category.all
  end

  # GET /document/categories/1
  # GET /document/categories/1.json
  def show
  end

  # GET /document/categories/new
  def new
    @document_category = Document::Category.new
  end

  # GET /document/categories/1/edit
  def edit
  end

  # POST /document/categories
  # POST /document/categories.json
  def create
    @document_category = Document::Category.new(document_category_params)

    respond_to do |format|
      if @document_category.save
        format.html { redirect_to @document_category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: @document_category }
      else
        format.html { render :new }
        format.json { render json: @document_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /document/categories/1
  # PATCH/PUT /document/categories/1.json
  def update
    respond_to do |format|
      if @document_category.update(document_category_params)
        format.html { redirect_to @document_category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @document_category }
      else
        format.html { render :edit }
        format.json { render json: @document_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /document/categories/1
  # DELETE /document/categories/1.json
  def destroy
    @document_category.destroy
    respond_to do |format|
      format.html { redirect_to document_categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document_category
      @document_category = Document::Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_category_params
      params.require(:document_category).permit(:title, :preview_ico)
    end
end
