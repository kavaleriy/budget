module Repairing::MapsHelper
  def get_address_title(repair)
    pattern = /^[0-9]+\./
    if repair.address.match pattern
      "#{t('repairing.maps.info_popup.info_coordinates')} :"
    else
      "#{t('repairing.maps.info_popup.info_adress')} :"
    end
  end

  def has_own_referer?
    # return true if iframe in our site. For show or hide buttons under map.
    referer = URI(request.referer).host if request.referer
    referer == request.host
  end
end
