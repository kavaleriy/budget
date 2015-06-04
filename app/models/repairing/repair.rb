class Repairing::Repair
  include Mongoid::Document

  belongs_to :map, class_name: 'Repairing::Map', autosave: true

  field :title, type: String
  field :description, type: String

  field :koatuu, type: String
  field :district, type: String
  field :street, type: String
  def address
    [district, street].compact.join(', ')
  end

  field :amount, type: Float

  field :coordinates, type: Array
  include Geocoder::Model::Mongoid
  geocoded_by :address               # can also be an IP address

  after_validation :geocode          # auto-fetch coordinates
end
