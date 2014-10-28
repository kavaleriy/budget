class BudgetFilesController < ApplicationController
  before_action :set_budget_file, only: [:get_sunburst_data, :get_bubbletree_data]

  # POST /revenues
  # POST /revenues.json
  def create par
    file = upload par[:file]

    @budget_file.title = if par[:title].empty?
      file[:name]
    else
      par[:title]
    end

    @budget_file.file = file[:path]

    respond_to do |format|
      if @budget_file.save
        @budget_file.load_file

        format.html { redirect_to @budget_file, notice: 'Revenue was successfully created.' }
        format.json { render :show, status: :created, location: @budget_file }
      else
        format.html { render :new }
        format.json { render json: @budget_file.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_sunburst_data
    render json: @budget_file.get_sunburst_data
  end

  def get_bubbletree_data
    render json: @budget_file.get_bubbletree_data
  end

  private

    def upload uploaded_io
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


end
