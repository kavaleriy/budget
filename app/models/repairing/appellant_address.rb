module Repairing
  # Address appellant for appeal
  class AppellantAddress
    include Mongoid::Document

    embedded_in :appeal, inverse_of: :address

    field :city, type: String
    field :street, type: String
    field :house, type: String
    field :apartment, type: String

    validates_presence_of :city, :street, :house
  end
end