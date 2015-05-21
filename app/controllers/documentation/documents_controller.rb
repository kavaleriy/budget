class Documentation::DocumentsController < ApplicationController

  before_action :set_documentation_document, only: [:show, :edit, :update, :destroy]

  # GET /documentation/documents
  # GET /documentation/documents.json
  def index
    @documentation_documents = Documentation::Document.all
  end

  # GET /documentation/documents/1
  # GET /documentation/documents/1.json
  def show
  end

  # GET /documentation/documents/new
  def new
    @documentation_document = Documentation::Document.new
  end

  # GET /documentation/documents/1/edit
  def edit
  end

  # POST /documentation/documents
  # POST /documentation/documents.json
  def create
    @documentation_document = Documentation::Document.new(documentation_document_params)
    @documentation_document.town = current_user.town
    @documentation_document.owner = current_user.email

    respond_to do |format|
      if @documentation_document.save
        format.js {
        }
        format.json { head :no_content, status: :created }
      else
        format.js
        format.json { render json: @documentation_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documentation/documents/1
  # PATCH/PUT /documentation/documents/1.json
  def update
    respond_to do |format|
      if @documentation_document.update(documentation_document_params)
        format.js
        format.json { render :show, status: :ok, location: @documentation_document }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @documentation_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documentation/documents/1
  # DELETE /documentation/documents/1.json
  def destroy
    @documentation_document.destroy
    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_documentation_document
      @documentation_document = Documentation::Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def documentation_document_params
      params.require(:documentation_document).permit(:category_id, :title, :description, :issued, :doc_file, :preview_ico)
    end
end
