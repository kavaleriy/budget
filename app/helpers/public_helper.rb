module PublicHelper
  def show_town_blazon(town)
    path = File.exist?(town.img.thumb.path.to_s) ? town.img.thumb.url : 'new_design/blason.svg'
    image_tag(path, class: 'img-responsive')
  end

  def eidos_logo
    logo_path = I18n.locale == :uk ? 'new_design/eidos-logo.png' : 'new_design/eidos-logo-en.png'
    image_tag(logo_path, class: 'img-responsive')
  end

  def embedFullUrl(url_path, protocol='https://')
    # path = "#{request.base_url}"
    path = "#{protocol}#{request.env['HTTP_HOST']}"
    full_URL = path + url_path

    # 'allowfullscreen' use for embed modules and portal_public_finances
    content_tag(:iframe, nil, src: full_URL, class: 'embed-responsive-item', frameborder: 0, style: 'width: 100%; height: 50vh;',
                allowfullscreen: 'true', mozallowfullscreen: 'true', webkitallowfullscreen: 'true')
  end

  def download_instruction(page_alias)
    case page_alias
      when 'repairing_maps_help'
        repairing_download_url
      when 'key_indicator_file_help'
        file_example = KeyIndicate::IndicatorFile.first
        unless file_example.nil?
          file_example.indicate_file.url
        end
      else
        nil
    end
  end

end