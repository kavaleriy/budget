#encoding: utf-8

namespace :repairing do

  desc "Calc repairing coordinates by addres"
  task :calc_coordinates => :environment  do |t|
    Repairing::Repair.where(:coordinates => nil).each do |repair|
      puts "repair: #{repair.id}\n\t#{repair.address}"
      puts "\t#{repair.address_to}" unless repair.address_to.blank?

      repair.coordinates = RepairingGeocoder.calc_coordinates(repair.address, repair.address_to)
      repair.save!

      puts "calculated => #{repair.coordinates}"
    end
  end

end
