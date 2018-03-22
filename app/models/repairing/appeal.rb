require 'file_size_validator'

module Repairing
  # Appeal for repair
  class Appeal
    include Mongoid::Document
    require 'carrierwave/mongoid'

    include Mongoid::Timestamps
    field :full_name, type: String
    field :email, type: String
    field :phone, type: String
    field :address, type: String
    field :recipients, type: Array, default: []
    field :text, type: String
    field :user_consent, type: Mongoid::Boolean
    field :approved, type: Mongoid::Boolean

    mount_uploader :file, FileUploader
    # used for update record with uploader
    # TODO: del skip_callback because file will not update
    skip_callback :update, :before, :store_previous_model_for_file

    embeds_one :address, class_name: 'Repairing::AppellantAddress'

    validates_presence_of :full_name, :email, :text, :user_consent
    validates :email, format: Devise.email_regexp

    file_size = 3
    validates :file,
              file_size: {
                maximum: file_size.megabytes.to_i,
                message: I18n.t('mongoid.errors.messages.error_max_file_size', file_size: file_size)
              }
  end
end