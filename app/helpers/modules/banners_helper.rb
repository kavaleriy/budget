module Modules::BannersHelper
  def get_img(banner)
    if banner.banner_img?
      banner.banner_img.thumb
    else
      banner.banner_url
    end
  end

  def get_banner_id(banners, i, move)
    case move
      when 'left'
        banners[i-1].nil? ? banners.last : banners[i-1]
      when 'right'
        banners[i+1].nil? ? banners.first : banners[i+1]
    end
  end
end
