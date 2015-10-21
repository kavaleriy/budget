module Documentation
  class LinkCategoriesController < ApplicationController
    before_action :authenticate_user!, except: [:index, :tree_root, :tree]

    before_action :set_documentation_link_category, only: [:show, :edit, :update, :destroy]

    # GET /documentation/link_categories
    # GET /documentation/link_categories.json
    def index
    end

    def tree_root
      @documentation_link_categories = Documentation::LinkCategory.tree_root
    end

    def tree
      @documentation_link_categories = Documentation::LinkCategory.tree(params[:id])
    end

    # GET /documentation/link_categories/1
    # GET /documentation/link_categories/1.json
    def show
      @links = Documentation::Link.where( :link_category_id => @documentation_link_category.id)
      respond_to do |format|
        format.js
      end
    end

    # GET /documentation/link_categories/indicator_file
    def new
      @documentation_link_category = Documentation::LinkCategory.new
    end

    # GET /documentation/link_categories/1/edit
    def edit
    end

    # POST /documentation/link_categories
    # POST /documentation/link_categories.json
    def create
      @documentation_link_category = Documentation::LinkCategory.new(documentation_link_category_params)
      @documentation_link_category.parent = Documentation::LinkCategory.find(documentation_link_category_params.link_category_id) if documentation_link_category_params.respond_to? :link_category_id

      respond_to do |format|
        if @documentation_link_category.save
          format.json { render :show, status: :created, location: @documentation_link_category }
        else
          format.json { render json: @documentation_link_category.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /documentation/link_categories/1
    # PATCH/PUT /documentation/link_categories/1.json
    def update
      new_position = documentation_link_category_params[:position].to_i
      new_category_id = documentation_link_category_params[:link_category_id]
      old_category_id = @documentation_link_category.link_category_id.to_s
      id = params[:id]

      recalc_positions(new_category_id, id, new_position)

      respond_to do |format|
        if @documentation_link_category.update(documentation_link_category_params)
          recalc_positions(old_category_id, nil) unless old_category_id == new_category_id

          format.js
          format.json { render :show, status: :ok, location: @documentation_link_category }
        else
          format.js { render js: 'alert("Помилка збереження")' }
          format.json { render json: @documentation_link_category.errors, status: :unprocessable_entity }
        end
      end
    end

    def recalc_positions(link_category_id, id, new_position = -1)
      position = 0
      Documentation::LinkCategory.where(:link_category_id => link_category_id).each{ |category|
        next if category.id.to_s == id
        position = new_position + 1 if position == new_position
        category.update(:position => position)
        puts "#{category.position} - #{category.title}"
        position += 1
      }

    end

    # DELETE /documentation/link_categories/1
    # DELETE /documentation/link_categories/1.json
    def destroy
      @documentation_link_category.destroy
      respond_to do |format|
        format.html { redirect_to documentation_link_categories_url, notice: 'Category was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      def set_documentation_link_category
        @documentation_link_category = Documentation::LinkCategory.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def documentation_link_category_params
        params.require(:documentation_link_category).permit(:link_category_id, :title, :preview_ico, :description, :position)
      end
  end
end