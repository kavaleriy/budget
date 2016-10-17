module Documentation
  class CategoriesController < ApplicationController
    layout 'application_admin'

    before_action :authenticate_user!, except: [:index, :tree_root, :tree]

    before_action :set_documentation_category, only: [:show, :edit, :update, :destroy]

    # GET /documentation/categories
    # GET /documentation/categories.json
    def index
    end

    def tree_root
      @documentation_categories = Documentation::Category.tree_root
    end

    def tree
      @documentation_categories = Documentation::Category.tree(params[:id])
    end

    # GET /documentation/categories/1
    # GET /documentation/categories/1.json
    def show
      @documents = Documentation::Document.where( :category_id => @documentation_category.id)
      respond_to do |format|
        format.js
      end
    end

    # GET /documentation/categories/indicator_file
    def new
      @documentation_category = Documentation::Category.new
    end

    # GET /documentation/categories/1/edit
    def edit
    end

    # POST /documentation/categories
    # POST /documentation/categories.json
    def create
      @documentation_category = Documentation::Category.new(documentation_category_params)
      @documentation_category.parent = Documentation::Category.find(documentation_category_params.category_id) if documentation_category_params.respond_to? :category_id

      respond_to do |format|
        if @documentation_category.save
          format.json { render :show, status: :created, location: @documentation_category }
        else
          format.json { render json: @documentation_category.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /documentation/categories/1
    # PATCH/PUT /documentation/categories/1.json
    def update
      new_position = documentation_category_params[:position].to_i
      new_category_id = documentation_category_params[:category_id]
      old_category_id = @documentation_category.category_id.to_s
      id = params[:id]

      recalc_positions(new_category_id, id, new_position)

      respond_to do |format|
        if @documentation_category.update(documentation_category_params)
          recalc_positions(old_category_id, nil) unless old_category_id == new_category_id

          format.js
          format.json { render :show, status: :ok, location: @documentation_category }
        else
          format.js { render js: 'alert("Помилка збереження")' }
          format.json { render json: @documentation_category.errors, status: :unprocessable_entity }
        end
      end
    end

    def recalc_positions(category_id, id, new_position = -1)
      position = 0
      Documentation::Category.where(:category_id => category_id).each{ |category|
        next if category.id.to_s == id
        position = new_position + 1 if position == new_position
        category.update(:position => position)
        puts "#{category.position} - #{category.title}"
        position += 1
      }

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
      def set_documentation_category
        @documentation_category = Documentation::Category.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def documentation_category_params
        params.require(:documentation_category).permit(:category_id, :title, :preview_ico, :description, :position)
      end
  end
end