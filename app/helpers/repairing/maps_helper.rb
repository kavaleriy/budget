module Repairing::MapsHelper
  def get_address_title
    pattern = /^[0-9]+\./
    if @repair.address.match pattern
      "#{t('repairing.maps.info_popup.info_coordinates')} :"
    else
      "#{t('repairing.maps.info_popup.info_adress')} :"
    end
  end
end
