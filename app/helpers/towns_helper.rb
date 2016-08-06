module TownsHelper
  def inline_svg(path)
    file_path = "#{Rails.root}/app/assets/images/#{path}"
    return File.read(file_path).html_safe if File.exists?(file_path)
    '(not found)'
  end
  def get_town_blazon(img)
    img.nil? ? 'default_image.png' : img
  end
end
