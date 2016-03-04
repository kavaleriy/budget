class ContentManager::PageContainersController < ApplicationController
  before_action :set_content_manager_page_container, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @page_containers = ContentManager::PageContainer.all
    respond_with(@page_containers)
  end

  def show
    respond_with(@page_container)
  end

  def new
    @page_container = ContentManager::PageContainer.new
    respond_with(@page_container)
  end

  def edit
  end

  def create
    @page_container = ContentManager::PageContainer.new(content_manager_page_container_params)
    @page_container.save
    respond_with(@page_container)
  end

  def update
    @page_container.update(content_manager_page_container_params)
    respond_with(@page_container)
  end

  def destroy
    @page_container.destroy
    respond_with(@page_container)
  end

  private
    def set_content_manager_page_container
      @page_container = ContentManager::PageContainer.find(params[:id])
    end

    def content_manager_page_container_params
      params.require(:content_manager_page_container).permit(:header,:content)
    end
end
