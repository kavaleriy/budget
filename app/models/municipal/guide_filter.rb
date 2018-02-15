module Municipal
  # upload guide filter file
  class GuideFilter
    include Mongoid::Document
    require 'carrierwave/mongoid'

    include Mongoid::Timestamps
    mount_uploader :file, FileUploader
    field :type_file, type: String
    field :type_enterprise, type: String

    scope :by_type, ->(type_e, type_f) { where(type_enterprise: type_e, type_file: type_f) }

    has_many :code_descriptions, class_name: 'Municipal::CodeDescription', dependent: :destroy

    validates_uniqueness_of :type_file, scope: :type_enterprise

    def publish_codes
      code_descriptions.where(publish: true)
    end
  end
end
