module Modules::BannersHelper
  def get_banner_id(banners, i, move)
    case move
      when 'left'
        banners[i-1].nil? ? banners.last : banners[i-1]
      when 'right'
        banners[i+1].nil? ? banners.first : banners[i+1]
    end
  end
end
