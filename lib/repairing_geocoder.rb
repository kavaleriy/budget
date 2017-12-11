require 'rubyXL'
class RepairingGeocoder

  def self.calc_coordinates(address, address_to)
    location = self.coordinates_by_addr(address)
    location1 = self.coordinates_by_addr (address_to)
    if location && location1
      [location, location1]
    else
      location
    end
  end

  private

  def self.coordinates_by_addr(addr, wait = 1)
    return if addr.blank?

    # geocoder with google correct worked without this gsub!()
    # addr.gsub!(/м[.]/i, '')

    coord = Geocoder.coordinates(addr)

    if coord.blank?
      return if wait > 8
      sleep wait
      coord = self.coordinates_by_addr(addr, wait * 2)
    end

    coord
  end


end