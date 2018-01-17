class Municipal::EnterpriseFilesController < ApplicationController
  before_action :set_municipal_enterprise_file, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @municipal_enterprise_files = Municipal::EnterpriseFile.all
    respond_with(@municipal_enterprise_files)
  end

  def show
    respond_with(@municipal_enterprise_file)
  end

  def new
    @municipal_enterprise_file = Municipal::EnterpriseFile.new
    respond_with(@municipal_enterprise_file)
  end

  def edit
  end

  def create
    @municipal_enterprise_file = Municipal::EnterpriseFile.new(enterprise_file_params)
    @municipal_enterprise_file.save
    respond_with(@municipal_enterprise_file)
  end

  def update
    @municipal_enterprise_file.update(enterprise_file_params)
    respond_with(@municipal_enterprise_file)
  end

  def destroy
    @municipal_enterprise_file.destroy
    respond_with(@municipal_enterprise_file)
  end

  private
    def set_municipal_enterprise_file
      @municipal_enterprise_file = Municipal::EnterpriseFile.find(params[:id])
    end

    def municipal_enterprise_file_params
      params[:municipal_enterprise_file]
    end
end
