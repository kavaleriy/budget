module PublicHelper
  def show_town_blazon(town)
    path = File.exist?(town.img.thumb.path.to_s) ? town.img.thumb.url : 'new_design/blason.svg'
    image_tag(path, class: 'img-responsive')
  end

  def eidos_logo
    #TODO: to else put english logo version path
    logo_path = I18n.locale == :uk ? 'new_design/eidos-logo.png' : 'new_design/eidos-logo-en.png'
    image_tag(logo_path, class: 'img-responsive')
  end

  def embedFullUrl(url_path)
    path = "#{request.base_url}"
    full_URL = path + url_path
    content_tag(:iframe, nil, src: full_URL, class: 'embed-responsive-item', :frameborder => 0, :width => '100%', :height => '611px')
  end

end