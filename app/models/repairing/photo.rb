require 'ext/string'
module Repairing
  class Photo
    require 'file_size_validator'

    include Mongoid::Document
    require 'carrierwave/mongoid'
    include Mongoid::Timestamps

    embedded_in :repairing_repair, class_name: 'Repairing::Repair'

    mount_uploader :image, Repairing::RepairPhotoUploader

    validates :image, presence: true

    # Not used now, because uploader not saved original image
    # file_size = 1
    # validates :image,
    #           file_size: {
    #             maximum: file_size.megabytes.to_i,
    #             message: I18n.t('mongoid.errors.messages.error_max_file_size', file_size: file_size)
    #           }
  end

end
