module PropertyParanoiaPhoto
  extend ActiveSupport::Concern

  def photo_from_paranoia(layer_property, properties_arr_count, index)
    address = Properting::Property.deleted.where(obj_address: layer_property.obj_address) if layer_property.obj_address.present?
    if address.present? && address.count > properties_arr_count
      address.each do |photos|
        if photos.destroyed?
          photos.try(:photos).each do |photo|
            layer_property.photos.push(photo)
            layer_property.save(validate: false)
          end
          photos.destroy!
        end
      end
    else
      # add photo only for one icon
      address.each do |photos|
        if photos.destroyed?
          photos.try(:photos).each do |photo|
            layer_property.photos.push(photo)
            layer_property.save(validate: false)
          end
          if properties_arr_count == (index - 1)
            photos.destroy!
          end
        end
      end
    end
  end
end
