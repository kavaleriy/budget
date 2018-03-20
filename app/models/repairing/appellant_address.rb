module Repairing
  # Address appellant for appeal
  class AppellantAddress
    include Mongoid::Document

    embedded_in :appeal, inverse_of: :address

    field :street, type: String
    field :house, type: String
    field :apartment, type: String
  end
end