#encoding: utf-8

namespace :properting do

  desc "Calc properting coordinates by addres"
  task :calc_coordinates => :environment  do |t|
    Properting::Property.where(:coordinates => nil).each do |property|
      puts "property: #{property.id}\n\t#{property.address}"
      puts "\t#{property.address_to}" unless property.address_to.blank?

      property.coordinates = RepairingGeocoder.calc_coordinates(property.address, property.address_to)
      property.save!

      puts "calculated => #{property.coordinates}"
    end
  end
end
