require 'ext/string'
module Properting
  class Photo
    require 'file_size_validator'

    include Mongoid::Document
    require 'carrierwave/mongoid'
    include Mongoid::Timestamps

    embedded_in :properting_property, class_name: 'Properting::Property'

    mount_uploader :image, Properting::PropertyPhotoUploader

    validates :image, presence: true
  end
end
