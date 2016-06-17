module ContentManager::PageContainersHelper
  def get_menu_list
    ContentManager::PageContainer.get_menu_list
  end

  def get_header_by_locale(content)
    return unless content
    res = 'empty'
    if check_locale_data?(content)
      locales = get_locale_for_translate
      unless  content.locale_data[locales].nil?
       res = content.locale_data[locales][:header] unless content.locale_data[locales][:header].empty?
      end
    end
    res

  end

  def get_content_by_locale(content)
    return unless content

    if check_locale_data?(content)
      locales = get_locale_for_translate
      unless  content.locale_data[locales].nil?
        content.locale_data[locales][:content].html_safe
      end
    end
  end

  def get_locale_for_translate
    params[:locale] || 'uk'
  end

  def check_locale_data?(content)
     content.locale_data.nil? ? false : true
  end

  def check_content_by_locale(content)
    if check_locale_data?(content)
      content.locale_data[get_locale_for_translate].nil?
    end

  end

end
