module ContentManager::PageContainersHelper
  def get_menu_list
    ContentManager::PageContainer.get_menu_list
  end

  def get_header_by_locale(content)
    content[params[:locale]][:header]
  end

  def get_content_by_locale(content)
    content[params[:locale]][:content]
  end
end
