module Repairing
  # Appeal for repair
  class Appeal
    include Mongoid::Document
    # require 'carrierwave/mongoid'

    include Mongoid::Timestamps
    field :text, type: String
    field :full_name, type: String
    field :email, type: String
    field :phone, type: String
    field :address, type: String
    field :user_consent, type: Mongoid::Boolean
    field :approved, type: Mongoid::Boolean

    embeds_one :address, class_name: 'AppellantAddress'
  end
end