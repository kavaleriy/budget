# frozen_string_literal: true

module Municipal
  class EnterprisesFile
    include Mongoid::Document
    require 'carrierwave/mongoid'

    include Mongoid::Timestamps

    scope :by_town, ->(id) { where(town: id) }

    belongs_to :owner, class_name: 'User'
    belongs_to :town, class_name: 'Town'
    has_many :enterprises, class_name: 'Municipal::Enterprise', dependent: :destroy

    mount_uploader :file, FileUploader

  end

end
