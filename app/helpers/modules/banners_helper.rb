module Modules::BannersHelper
  def get_img(banner)
    if banner.banner_img?
      banner.banner_img.thumb
    else
      banner.banner_url
    end
  end
end
