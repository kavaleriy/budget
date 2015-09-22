class Repairing::CategoriesController < ApplicationController
  before_action :set_repairing_category, only: [:show, :edit, :update, :destroy]

  # GET /repairing/categories
  # GET /repairing/categories.json
  def index
    @repairing_categories = Repairing::Category.all
  end

  # GET /repairing/categories/1
  # GET /repairing/categories/1.json
  def show
  end

  def tree_root
    @documentation_categories = Documentation::Category.tree_root
  end

  def tree
    @documentation_categories = Documentation::Category.tree(params[:id])
  end

  # GET /repairing/categories/new
  def new
    @repairing_category = Repairing::Category.new
  end

  # GET /repairing/categories/1/edit
  def edit
  end

  # POST /repairing/categories
  # POST /repairing/categories.json
  def create
    @repairing_category = Repairing::Category.new(repairing_category_params)

    respond_to do |format|
      if @repairing_category.save
        format.html { redirect_to @repairing_category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: @repairing_category }
      else
        format.html { render :new }
        format.json { render json: @repairing_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repairing/categories/1
  # PATCH/PUT /repairing/categories/1.json
  def update
    respond_to do |format|
      if @repairing_category.update(repairing_category_params)
        format.html { redirect_to @repairing_category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @repairing_category }
      else
        format.html { render :edit }
        format.json { render json: @repairing_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repairing/categories/1
  # DELETE /repairing/categories/1.json
  def destroy
    @repairing_category.destroy
    respond_to do |format|
      format.html { redirect_to repairing_categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repairing_category
      @repairing_category = Repairing::Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repairing_category_params
      params.require(:repairing_category).permit(:title, :img)
    end
end
