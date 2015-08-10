class Documentation::BranchesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  load_and_authorize_resource

  before_action :set_documentation_branch, only: [:show, :edit, :update, :destroy]

  def search
    respond_to do |format|
      q = params[:query]
      @branches = Documentation::Branch.where(:title => Regexp.new("^#{q}.*"))
      format.json
    end
  end

  # GET /documentation/branches
  # GET /documentation/branches.json
  def index
    @documentation_branches = Documentation::Branch.all
  end

  # GET /documentation/branches/1
  # GET /documentation/branches/1.json
  def show
  end

  # GET /documentation/branches/new
  def new
    @documentation_branch = Documentation::Branch.new
  end

  # GET /documentation/branches/1/edit
  def edit
  end

  # POST /documentation/branches
  # POST /documentation/branches.json
  def create
    @documentation_branch = Documentation::Branch.new(documentation_branch_params)

    respond_to do |format|
      if @documentation_branch.save
        format.html { redirect_to @documentation_branch, notice: 'Branch was successfully created.' }
        format.json { render :show, status: :created, location: @documentation_branch }
      else
        format.html { render :new }
        format.json { render json: @documentation_branch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documentation/branches/1
  # PATCH/PUT /documentation/branches/1.json
  def update
    respond_to do |format|
      if @documentation_branch.update(documentation_branch_params)
        format.html { redirect_to @documentation_branch, notice: 'Branch was successfully updated.' }
        format.json { render :show, status: :ok, location: @documentation_branch }
      else
        format.html { render :edit }
        format.json { render json: @documentation_branch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documentation/branches/1
  # DELETE /documentation/branches/1.json
  def destroy
    @documentation_branch.destroy
    respond_to do |format|
      format.html { redirect_to documentation_branches_url, notice: 'Branch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_documentation_branch
      @documentation_branch = Documentation::Branch.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def documentation_branch_params
      params.require(:documentation_branch).permit(:title, :color)
    end
end
