class BudgetFilesController < ApplicationController
  before_action :set_budget_file, only: [:show, :edit, :editinfo, :update, :destroy, :get_sunburst_data, :get_bubbletree_data]

  # GET /revenues
  # GET / revenues.json
  def index
    @budget_files = BudgetFile.all
  end

  def show
  end

  def upload
    @budget_file = BudgetFile.new
  end

  # POST /revenues
  # POST /revenues.json
  def create
    @budget_file = BudgetFile.new()

    file = upload_io budget_file_params[:file]

    @budget_file.title = budget_file_params[:title].empty? ? file[:name] : budget_file_params[:title]

    @budget_file.file = file[:path]

    @budget_file.load_file
    @budget_file.prepare

    respond_to do |format|
      if @budget_file.save
        format.html { redirect_to @budget_file, notice: 'File was successfully uploaded.' }
        format.json { render :show, status: :created, location: @budget_file }
      else
        format.html { render :new }
        format.json { render json: @budget_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /revenues/1
  # DELETE /revenues/1.json
  def destroy
    @budget_file.destroy
    respond_to do |format|
      format.html { redirect_to budget_files_url, notice: 'File was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def get_sunburst_data
    render json: @budget_file.get_sunburst_tree
  end

  def get_bubbletree_data
    render json: @budget_file.get_bubble_tree
  end

  private

    def upload_io uploaded_io
      file_name = uploaded_io.original_filename
      file_path = Rails.root.join('public', 'files', file_name)

      File.open(file_path, 'wb') do |file|
        file.write(uploaded_io.read)
      end

      { name: file_name, path: file_path }
    end

    def set_budget_file
      @budget_file = BudgetFile.find(params[:id])
    end

  def budget_file_params
    params.require(:budget_file).permit(:title, :file)
  end

end
