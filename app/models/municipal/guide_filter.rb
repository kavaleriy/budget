module Municipal
  # upload guide filter file
  class GuideFilter
    include Mongoid::Document
    require 'carrierwave/mongoid'

    include Mongoid::Timestamps
    mount_uploader :file, FileUploader
    field :type_file, type: String
    field :type_enterprise, type: String

    has_many :code_descriptions, class_name: 'Municipal::CodeDescription', dependent: :destroy
  end
end
