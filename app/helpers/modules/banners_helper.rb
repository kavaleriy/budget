module Modules::BannersHelper
  def get_banner_id(banners, i, move)
    case move
      when 'left'
        banners[i-1].nil? ? banners.last : banners[i-1]
      when 'right'
        banners[i+1].nil? ? banners.first : banners[i+1]
    end
  end

  def get_banner_img banner
    image_tag(banner.banner_img.thumb, :title => banner.title, class: 'img-responsive')
  end

  def get_banner banner
    if banner.banner_url?
      link_to get_banner_img(banner), banner.banner_url, target: '_blank'
    else
      get_banner_img(banner)
    end
  end
end
