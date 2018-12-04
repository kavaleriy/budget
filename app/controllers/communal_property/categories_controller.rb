class CommunalProperty::CategoriesController < ApplicationController
    layout 'application_admin'

    before_action :set_category, only: [:show, :edit, :update, :destroy]

    # GET /repairing/categories
    # GET /repairing/categories.json
    def index
      @categories = CommunalProperty::Category.all
    end

    # GET /repairing/categories/1
    # GET /repairing/categories/1.json
    def show
      @categories = subcategories(@category.id)
      respond_to do |format|
        format.js
      end
    end

    def tree_root
      @categories = CommunalProperty::Category.tree_root
    end

    def tree
      @categories = CommunalProperty::Category.tree(params[:id])
    end

    # GET /repairing/categories/new
    def new
      @category = CommunalProperty::Category.new
    end

    # GET /repairing/categories/1/edit
    def edit
    end

    # POST /repairing/categories
    # POST /repairing/categories.json
    def create
      @category = CommunalProperty::Category.new(category_params)
      @category.parent = CommunalProperty::Category.find(category_params.category_id) if category_params.respond_to? :category_id

      respond_to do |format|
        if @category.save
          format.json { render :show, status: :created, location: @category }
        else
          format.json { render json: @category.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /repairing/categories/1
    # PATCH/PUT /repairing/categories/1.json
    def update
      unless category_params[:position].nil? && category_params[:category_id].nil?
        new_position = category_params[:position].to_i
        new_category_id = category_params[:category_id]
        old_category_id = @category.category_id.to_s
        recalc_positions(new_category_id, params[:id], new_position)
      end

      respond_to do |format|
        if @category.update(category_params)
          recalc_positions(old_category_id, nil) unless old_category_id.nil? && new_category_id.nil? && old_category_id == new_category_id
          @flash = {"message" => "Дані успішно збережені", "class" => "alert-success" }
          format.js
          format.json { render :show, status: :ok, location: @category }
        else
          @flash = {"message" => "Помилка збереження даних.", "class" => "alert-danger" }
          format.js
          format.json { render json: @category.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /repairing/categories/1
    # DELETE /repairing/categories/1.json
    def destroy
      subcategories(@category.id).each{|category|
        category.destroy
      }
      @category.destroy
      respond_to do |format|
        format.html { redirect_to categories_url, notice: 'Category was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    def recalc_positions(category_id, id, new_position = -1)
      position = 0
      subcategories(category_id).each{ |category|
        next if category.id.to_s == id
        position = new_position + 1 if position == new_position
        category.update(position: position)
        puts "#{category.position} - #{category.title}"
        position += 1
      }

    end
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = CommunalProperty::Category.find(params[:id])
    end

    def subcategories(category_id)
      CommunalProperty::Category.where(category_id: category_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:communal_property_category).permit(:category_id, :title, :icon, :color, :position, :img, :locale)
    end
  end

