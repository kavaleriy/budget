class Documentation::DocumentsController < ApplicationController
  helper_method :sort_column, :sort_direction

  before_action :authenticate_user!, except: [:index]
  load_and_authorize_resource

  before_action :set_documentation_document, only: [:show, :edit, :lock, :update, :destroy]

  # GET /documentation/documents
  # GET /documentation/documents.json
  def index
    @documentation_documents = Documentation::Document.order(sort_column + " " + sort_direction)
    @documentation_documents = @documentation_documents.where(:town.in => params["town_select"].split(',')) unless params["town_select"].blank?
    @documentation_documents = @documentation_documents.where(:branch.in => params["branch_select"]) unless params["branch_select"].blank?

    @documentation_documents = @documentation_documents.where(:yearFrom.lte => params["year"].to_i, :yearTo.gte => params["year"].to_i) unless params["year"].blank?

    @documentation_documents = @documentation_documents.where(:title => Regexp.new(".*"+params["q"]+".*")) unless params["q"].blank?

    @documentation_documents = @documentation_documents.where(:locked => params["locked"]) unless params["locked"].blank?

    @documentation_documents.page params[:page]

    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET /documentation/documents/1
  # GET /documentation/documents/1.json
  def show
  end

  # GET /documentation/documents/indicator_file
  def new
    @documentation_document = Documentation::Document.new
  end

  # GET /documentation/documents/1/edit
  def edit
  end

  # POST /documentation/documents
  # POST /documentation/documents.json
  def create
    @documents = []

    params[:documentation_document][:town_id].blank? ? town = Town.where(title: current_user.town).first_or_create : town = Town.find(params[:documentation_document][:town_id])

    params['doc_file'].each do |f|
      doc = Documentation::Document.new(documentation_document_params)
      doc.doc_file = f

      doc.town = town

      doc.owner = current_user

      current_user.has_role?(:admin) ? doc.locked = false : doc.locked = true
      doc.save!

      @documents << doc
    end unless params['doc_file'].nil?

    respond_to do |format|
      format.js
      format.json { head :no_content, status: :created }
    end

  end

  # PATCH/PUT /documentation/documents/1
  # PATCH/PUT /documentation/documents/1.json
  def update
    respond_to do |format|
      if @documentation_document.update!(documentation_document_params)
        format.js
        format.json { render :show, status: :ok, location: @documentation_document }
      else
        format.js { render status: :unprocessable_entity }
        format.json { render json: @documentation_document.errors, status: :unprocessable_entity }
      end
    end
  end

  def lock
    if params[:locked]
      @documentation_document.locked = true
    else
      @documentation_document.locked = false
    end

    respond_to do |format|
      if @documentation_document.save
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

    def sort_column
      Documentation::Document.fields.keys.include?(params[:sort]) ? params[:sort] : "title"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_documentation_document
      @documentation_document = Documentation::Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def documentation_document_params
      params.require(:documentation_document).permit(:category_id, :title, :branch, :town, :town_id, :description, :year, :yearFrom, :yearTo, :locked, :sort, :direction)
    end
end
