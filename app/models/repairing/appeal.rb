require 'file_size_validator'

module Repairing
  # Appeal for repair
  class Appeal
    include Mongoid::Document
    include Mongoid::Enum
    require 'carrierwave/mongoid'

    include Mongoid::Timestamps
    field :full_name, type: String
    field :email, type: String
    field :phone, type: String
    field :address, type: String
    field :text, type: String
    field :user_consent, type: Mongoid::Boolean
    field :declined_text, type: String

    enum :status, %i[pending approved declined], default: :pending

    mount_uploader :file, FileUploader
    # used for update record with uploader
    # TODO: del skip_callback because file will not update
    skip_callback :update, :before, :store_previous_model_for_file

    scope :by_create, -> { order(created_at: :desc) }

    embeds_one :address, class_name: 'Repairing::AppellantAddress'
    belongs_to :repair, class_name: 'Repairing::Repair'
    belongs_to :scenario, class_name: 'Repairing::AppealScenario'
    has_and_belongs_to_many :recipients, class_name: 'TownEmail'

    validates_presence_of :full_name, :email, :text, :user_consent
    validates :email, format: Devise.email_regexp
    validates :text, length: 100..2500
    # validation only for disapprove appeal
    validates :declined_text, length: 50..2500, on: :update, if: :declined?

    file_size = 3
    validates :file,
              file_size: {
                maximum: file_size.megabytes.to_i,
                message: I18n.t('mongoid.errors.messages.error_max_file_size', file_size: file_size)
              }

    def town_title
      repair.layer.town.title rescue nil
    end

    def category_title
      repair.layer.repairing_category.title rescue nil
    end

  end
end