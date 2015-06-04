class RepairMap::Location
  include Mongoid::Document

  field :street
  def address
    [street].compact.join(', ')
  end


  field :coordinates, :type => Array
  include Geocoder::Model::Mongoid
  geocoded_by :address               # can also be an IP address

  after_validation :geocode          # auto-fetch coordinates
end
