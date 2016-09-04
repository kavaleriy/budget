module Modules::BannersHelper
  def get_banner_id(banners, i, move)
    case move
      when 'left'
        banners[i-1].nil? ? banners.last : banners[i-1]
      when 'right'
        banners[i+1].nil? ? banners.first : banners[i+1]
    end
  end

  def get_img(img, title)
    image_tag(img, :title => title, class: 'img-responsive')
  end

  def get_item(item, type)
    # use 'case' for banners and partners because they have different names fields in DB
    # TODO: in feature improve this method
    case type
    when 'banner'
      if item.url?
        link_to get_img(item.banner_img, item.title), item.url, target: '_blank'
      else
        get_img(item.banner_img, item.title)
      end
    when 'partner'
      if item.url?
        link_to get_img(item.logo, item.name), item.url, target: '_blank'
      else
        get_img(item.logo, item.name)
      end
    end
  end
end
