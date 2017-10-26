module PublicHelper
  def show_town_blazon(town)
    path = File.exist?(town.img.thumb.path.to_s) ? town.img.thumb.url : 'new_design/blason.svg'
    image_tag(path, class: 'img-responsive')
  end

  def eidos_logo
    logo_path = I18n.locale == :uk ? 'new_design/eidos-logo.png' : 'new_design/eidos-logo-en.png'
    image_tag(logo_path, class: 'img-responsive')
  end

  def embed_full_url(url_path)
    # TODO: setting nginx config for https protocol
    # https://github.com/cerebris/jsonapi-resources/issues/501
    # because I can't get https from request.base_url
    protocol = 'https://'
    base_url = "#{protocol}#{request.host_with_port}"
    full_url = base_url + url_path

    # 'allowfullscreen' use for embed modules and portal_public_finances
    content_tag(:iframe, nil, src: full_url, class: 'embed-responsive-item', frameborder: 0, style: 'width: 100%; height: 50vh;',
                allowfullscreen: 'true', mozallowfullscreen: 'true', webkitallowfullscreen: 'true')
  end

end
