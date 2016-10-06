class ContentManager::PageContainersController < AdminController
  require 'cyrillizer'

  before_action :set_content_manager_page_container, only: [:show, :edit, :update, :destroy]
  before_action :set_locale_content, only: [:create, :update]
  before_action :get_menu_list,only: [:new, :edit,:create,:update]
  respond_to :html

  def index
    @page_containers = ContentManager::PageContainer.get_all_menu
    @info_pages = ContentManager::PageContainer.get_info_pages
    @instruction_pages = ContentManager::PageContainer.get_instruction_pages
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
    # set alias from header of locale data
    # transliterate alias to latin
    @page_container.alias = content_manager_page_container_params[:locale_data][I18n.locale][:header].to_lat

    if @page_container.save
      flash[:notice] = t('page_containers.create.success')
    end

    respond_with(@page_container)
  end

  def update
    except_locale_data = content_manager_page_container_params.except!(:locale_data)

    @page_container.write_attributes(except_locale_data)
    @page_container.locale_data.merge!(content_manager_page_container_params[:locale_data])
    @page_container.save

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

    def get_menu_list
      @menu_list = ContentManager::PageContainer.get_menu_list.to_a
    end

    def content_manager_page_container_params
      locale_for_data = params[:locale].to_s || :uk
      params.require(:content_manager_page_container).permit(:header,:content,:alias,:p_id,
                                                             :locale_data => [locale_for_data => [:content,:header]])
    end

    def set_locale_content

    end
end
