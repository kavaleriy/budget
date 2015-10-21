module Documentation
  class LinksController < ApplicationController

    before_action :authenticate_user!, except: [:index]
    load_and_authorize_resource

    before_action :set_documentation_link, only: [:show, :edit, :lock, :update, :destroy]



    # GET /documentation/links/1
    # GET /documentation/links/1.json
    def show
    end

    # GET /documentation/links/indicator_file
    def new
      @documentation_document = Documentation::Document.new
    end

    # GET /documentation/documents/1/edit
    def edit
    end

    # POST /documentation/links
    # POST /documentation/links.json
    def create
      @link = Documentation::Link.new(documentation_link_params)
      respond_to do |format|
        if @link.save
          format.js
          format.json { head :no_content, status: :created }
          # format.json { render :create, status: :created, location: @link }
        else
          format.json { render json: @link.errors, status: :unprocessable_entity }
        end
        # format.js
        # format.json { head :no_content, status: :created }
      end

    end

    # PATCH/PUT /documentation/links/1
    # PATCH/PUT /documentation/links/1.json
    def update
      respond_to do |format|
        if @documentation_link.update!(documentation_link_params)
          format.js
          format.json { render :show, status: :ok, location: @documentation_link }
        else
          format.js { render status: :unprocessable_entity }
          format.json { render json: @documentation_link.errors, status: :unprocessable_entity }
        end
      end
    end



    # DELETE /documentation/documents/1
    # DELETE /documentation/documents/1.json
    def destroy
      @documentation_link.destroy
      respond_to do |format|
        format.js
        format.json { head :no_content }
      end
    end

    private

      # Use callbacks to share common setup or constraints between actions.
      def set_documentation_link
        @documentation_link = Documentation::Link.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def documentation_link_params
        params.require(:documentation_link).permit(:link_category_id, :title, :value, :yearFrom, :yearTo, :town)
      end
  end
end