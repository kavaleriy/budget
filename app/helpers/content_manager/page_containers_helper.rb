module ContentManager::PageContainersHelper
  def get_menu_list
    ContentManager::PageContainer.get_menu_list
  end

  def get_header_by_locale(content,locals = '')
    # binding.pry
    return unless content
    if locals.empty?
      locals = params[:locale] || :uk
      unless content[locals].nil?
        content[locals][:header]
      end
    else
      unless content[locals].nil?
        content[locals][:header]
      end
    end
  end

  def get_content_by_locale(content,locals = '')
    return unless content

    if locals.empty?
      content[params[:locale]][:content]
    else
      unless content[locals].nil?
        content[locals][:content]
      end
    end

  end

  def get_locale_for_translate
    params[:locale] || 'uk'
  end
end
