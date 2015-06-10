class Repairing::Repair
  include Mongoid::Document

  belongs_to :map, class_name: 'Repairing::Map'

  field :title, type: String
  field :description, type: String
  field :district, type: String
  field :street, type: String
  field :amount, type: Float
  field :repair_date, type: Date

  field :coordinates, type: Array
  field :geom_type, type: String

  def address
    [district, street].compact.join(', ')
  end

  # include Geocoder::Model::Mongoid
  # geocoded_by :address               # can also be an IP address
  #
  # after_validation :geocode          # auto-fetch coordinates
end
