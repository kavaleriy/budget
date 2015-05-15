class Documentation::CategoriesController < ApplicationController
  before_action :set_documentation_category, only: [:show, :edit, :update, :destroy]

  # GET /documentation/categories
  # GET /documentation/categories.json
  def index
    @documentation_categories = Documentation::Category.all
  end

  def tree_root
    @documentation_categories = Documentation::Category.where( :category_id => nil)
  end

  def tree
    @documentation_categories = Documentation::Category.all
  end

  # GET /documentation/categories/1
  # GET /documentation/categories/1.json
  def show
  end

  # GET /documentation/categories/new
  def new
    @documentation_category = Documentation::Category.new
  end

  # GET /documentation/categories/1/edit
  def edit
  end

  # POST /documentation/categories
  # POST /documentation/categories.json
  def create
    binding.pry
    @documentation_category = Documentation::Category.new(documentation_category_params)

    respond_to do |format|
      if @documentation_category.save
        format.html { redirect_to @documentation_category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: @documentation_category }
      else
        format.html { render :new }
        format.json { render json: @documentation_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documentation/categories/1
  # PATCH/PUT /documentation/categories/1.json
  def update
    respond_to do |format|
      if @documentation_category.update(documentation_category_params)
        format.html { redirect_to @documentation_category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @documentation_category }
      else
        format.html { render :edit }
        format.json { render json: @documentation_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documentation/categories/1
  # DELETE /documentation/categories/1.json
  def destroy
    @documentation_category.destroy
    respond_to do |format|
      format.html { redirect_to documentation_categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_documentation_category
      @documentation_category = Documentation::Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def documentation_category_params
      params.require(:documentation_category).permit(:category_id, :title, :preview_ico)
    end
end
