class Municipal::EnterpriseFilesController < ApplicationController
  before_action :set_municipal_enterprise_file, only: [:show, :edit, :update, :destroy]
  before_action :set_enterprises, only: [:new, :edit]

  respond_to :html

  def index
    @municipal_enterprise_files = Municipal::EnterpriseFile.all
    respond_with(@municipal_enterprise_files)
  end

  # def show
  #   respond_with(@municipal_enterprise_file)
  # end

  def new
    @municipal_enterprise_file = Municipal::EnterpriseFile.new
    respond_with(@municipal_enterprise_file)
  end

  # def edit; end

  def create
    @municipal_enterprise_file = Municipal::EnterpriseFile.new(enterprise_file_params)

    respond_to do |format|
      if @municipal_enterprise_file.save
        format.html { redirect_to municipal_enterprise_files_url, notice: 'Файл успішно додано.' }
      else
        format.html { render action: 'new' }
        format.json { render json: @municipal_enterprise_file.errors, status: :unprocessable_entity }
      end
    end
    # respond_with(@municipal_enterprise_file)
  end

  # def update
  #   @municipal_enterprise_file.remove_file! if enterprise_file_params[:file].present?
  #   @municipal_enterprise_file.update(enterprise_file_params)
  #   respond_with(@municipal_enterprise_file)
  # end

  def destroy
    @municipal_enterprise_file.destroy
    respond_with(@municipal_enterprise_file)
  end

  private

  def set_enterprises
    @enterprises = Municipal::Enterprise.by_town(current_user.town_model)
    @type_files = Municipal::EnterpriseFile.type_files
  end

  def set_municipal_enterprise_file
    @municipal_enterprise_file = Municipal::EnterpriseFile.find(params[:id])
  end

  def enterprise_file_params
    params.require(:municipal_enterprise_file).permit(:enterprise, :file_type, :year, :file)
  end
end
