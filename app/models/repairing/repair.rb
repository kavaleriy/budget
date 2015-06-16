class Repairing::Repair
  include Mongoid::Document

  belongs_to :map, class_name: 'Repairing::Map'

  field :title, type: String
  field :description, type: String
  field :amount, type: Float
  field :repair_date, type: Date

  field :address, type: String
  field :address_to, type: String
  field :coordinates, type: Array

  # include Geocoder::Model::Mongoid
  # geocoded_by :address               # can also be an IP address
  #
  # after_validation :geocode          # auto-fetch coordinates
end
