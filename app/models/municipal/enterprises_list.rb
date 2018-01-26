# frozen_string_literal: true

module Municipal
  # upload files with enterprises
  class EnterprisesList
    include Mongoid::Document
    require 'carrierwave/mongoid'

    include Mongoid::Timestamps
    mount_uploader :file, FileUploader

    scope :by_town, ->(id) { where(town: id) }

    belongs_to :owner, class_name: 'User'
    belongs_to :town, class_name: 'Town'
    has_many :enterprises, class_name: 'Municipal::Enterprise'

  end
end
