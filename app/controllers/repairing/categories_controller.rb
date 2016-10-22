# class Repairing::CategoriesController < ApplicationController
class Repairing::CategoriesController < AdminController
  layout 'application_admin'

  before_action :set_repairing_category, only: [:show, :edit, :update, :destroy]

  # GET /repairing/categories
  # GET /repairing/categories.json
  def index
    @repairing_categories = Repairing::Category.all
  end

  # GET /repairing/categories/1
  # GET /repairing/categories/1.json
  def show
    @repairing_categories = repairing_categories(@repairing_category.id)
    respond_to do |format|
      format.js
    end
  end

  def tree_root
    @repairing_categories = Repairing::Category.tree_root
  end

  def tree
    @repairing_categories = Repairing::Category.tree(params[:id])
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
    @repairing_category.parent = Repairing::Category.find(repairing_category_params.category_id) if repairing_category_params.respond_to? :category_id

    respond_to do |format|
      if @repairing_category.save
        format.json { render :show, status: :created, location: @repairing_category }
      else
        format.json { render json: @repairing_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repairing/categories/1
  # PATCH/PUT /repairing/categories/1.json
  def update

    unless repairing_category_params[:position].nil? && repairing_category_params[:category_id].nil?
      new_position = repairing_category_params[:position].to_i
      new_category_id = repairing_category_params[:category_id]
      old_category_id = @repairing_category.category_id.to_s
      recalc_positions(new_category_id, params[:id], new_position)
    end

    respond_to do |format|
      if @repairing_category.update(repairing_category_params)
        recalc_positions(old_category_id, nil) unless old_category_id.nil? && new_category_id.nil? && old_category_id == new_category_id
        @flash = {"message" => "Дані успішно збережені", "class" => "alert-success" }
        format.js
        format.json { render :show, status: :ok, location: @repairing_category }
      else
        @flash = {"message" => "Помилка збереження даних.", "class" => "alert-danger" }
        format.js
        format.json { render json: @repairing_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repairing/categories/1
  # DELETE /repairing/categories/1.json
  def destroy
    repairing_categories(@repairing_category.id).each{|category|
      category.destroy
    }
    @repairing_category.destroy
    respond_to do |format|
      format.html { redirect_to repairing_categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def recalc_positions(category_id, id, new_position = -1)
      position = 0
      repairing_categories(category_id).each{ |category|
        next if category.id.to_s == id
        position = new_position + 1 if position == new_position
        category.update(position: position)
        puts "#{category.position} - #{category.title}"
        position += 1
      }

    end
    # Use callbacks to share common setup or constraints between actions.
    def set_repairing_category
      @repairing_category = Repairing::Category.find(params[:id])
    end

    def repairing_categories(category_id)
      Repairing::Category.where(category_id: category_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repairing_category_params
      params.require(:repairing_category).permit(:category_id, :title, :icon, :color, :position, :img, :locale)
    end
end
