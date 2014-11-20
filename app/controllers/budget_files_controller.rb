class BudgetFilesController < ApplicationController
  before_action :set_budget_file, only: [:show, :edit, :editinfo, :update, :destroy, :get_sunburst_data, :get_bubbletree_data]

  before_action :authenticate_user!, only: [:index, :upload, :edit, :editinfo]
  #load_and_authorize_resource


  # GET /revenues
  # GET / revenues.json
  def index
    @budget_files = view_context.get_budget_files
  end

  def show
  end

  def upload
    @budget_file = BudgetFile.new
  end

  # POST /revenues
  # POST /revenues.json
  def create
    @budget_file = BudgetFile.new
    @budget_file.owner_email = current_user.email unless current_user.nil?

    file = upload_io budget_file_params[:file]

    @budget_file.title = budget_file_params[:title].empty? ? file[:name] : budget_file_params[:title]

    @budget_file.file = file[:path]

    @budget_file.load_file
    @budget_file.prepare

    respond_to do |format|
      if @budget_file.save
        format.html { redirect_to @budget_file, notice: 'Дані успішно завантажені.' }
        format.json { render :show, status: :created, location: @budget_file }
      else
        format.html { render :new }
        format.json { render json: @budget_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /revenues/1
  # PATCH/PUT /revenues/1.json
  def update
    if current_user and (@budget_file.owner_email == current_user.email or current_user.has_role? :admin)
      tree_info = @budget_file['tree_info'].deep_dup
      params[:taxonomy].each do |key, value|
        value.each { |val_key, val_val|
          val_val.keys.each { |val_key_key|
            tree_info[CGI.unescape key][CGI.unescape val_key][CGI.unescape val_key_key] = val_val[CGI.unescape val_key_key]
          }
        }
      end unless params[:taxonomy].nil?

      # rows = []
      # params[:rows].each { |key, value|
      #   binding.pry
      #   rows[key]['amount'] = value[key].to_i
      # } unless params[:rows].nil?
      # @budget_file.prepare

      respond_to do |format|
        if @budget_file.update(budget_file_params.merge({:tree_info => tree_info}))
        #if @revenue.update(revenue_params.merge({:tree_info => tree_info, :rows => rows}))
          format.html { redirect_to @budget_file, notice: 'Дані збережені успішно.' }
          format.json { render :show, status: :ok, location: @budget_file }
        else
          format.html { render :edit }
          format.json { render json: @budget_file.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @budget_file, :flash => { :error => 'Ви не маєте доступу до редагування документу.' } }
      end
    end

  end

  # DELETE /revenues/1
  # DELETE /revenues/1.json
  def destroy
    if current_user and (@budget_file.owner_email == current_user.email or current_user.has_role? :admin)
      @budget_file.destroy
      respond_to do |format|
        format.html { redirect_to budget_files_url, notice: 'Дані успішно видалені.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to @budget_file, :flash => { :error => 'Ви не маєте доступу до видалення документу.' } }
      end
    end
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
