module TownsHelper
  def inline_svg(path)
    file_path = "#{Rails.root}/app/assets/images/#{path}"
    return File.read(file_path).html_safe if File.exists?(file_path)
    '(not found)'
  end

  def get_town_blazon(img)
    img.nil? ? '' : img
  end

  def town_english_title(title)
    #TODO: rewrite
    #WARN! It's ad hoc for one town, maybe deleted after town translation

    if I18n.locale == :en && title == 'Демонстрація типового профілю міста'
      'Demonstration of a typical city profile'
    else
      title
    end
  end

end
