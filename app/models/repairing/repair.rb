class Repairing::Repair
  include Mongoid::Document

  belongs_to :map, class_name: 'Repairing::Map'

  field :title, type: String
  field :koatuu, type: String
  field :district, type: String
  field :street, type: String
  field :description, type: String
  field :amount, type: Float
  field :coordinates, type: Array

  def address
    [district, street].compact.join(', ')
  end

  # include Geocoder::Model::Mongoid
  # geocoded_by :address               # can also be an IP address
  #
  # after_validation :geocode          # auto-fetch coordinates
end
