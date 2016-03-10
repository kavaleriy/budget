module ContentManager::PageContainersHelper
  def get_menu_list
    ContentManager::PageContainer.get_menu_list
  end

  def get_header_by_locale(content,locals = '')
    if locals.empty?
      content[params[:locale]][:header]
    else
      unless content[locals].nil?
        content[locals][:header]
      end
    end
  end

  def get_content_by_locale(content,locals = '')
    if locals.empty?
      content[params[:locale]][:content]
    else
      unless content[locals].nil?
        content[locals][:content]
      end
    end

  end
end
