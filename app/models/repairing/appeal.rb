module Repairing
  # Appeal for repair
  class Appeal
    include Mongoid::Document
    # require 'carrierwave/mongoid'

    include Mongoid::Timestamps
    field :full_name, type: String
    field :email, type: String
    field :phone, type: String
    field :address, type: String
    field :recipients, type: Array, default: []
    field :text, type: String
    field :user_consent, type: Mongoid::Boolean
    field :approved, type: Mongoid::Boolean

    embeds_one :address, class_name: 'Repairing::AppellantAddress'

    validates_presence_of :full_name, :email, :text, :user_consent
    validates :email, format: Devise.email_regexp
  end
end