namespace :repairing_repairs do
  desc 'Set start_date'
  task set_start_date: :environment do
    counter = 0
    old_date_repairs = Repairing::Repair.where(:repair_date.exists => true, :repair_date.ne => nil, :repair_start_date.exists => false)
    puts "#{old_date_repairs.count} repairs selected"

    old_date_repairs.each do |repair|
      if repair.coordinates.blank?
        puts "#{counter} not changed, repair_id - #{repair.id}, layer_id - #{repair.layer_id}"
        next
      end

      repair.repair_start_date = repair.repair_date

      repair.spending_units = 'no data'         unless repair.spending_units
      repair.edrpou_spending_units = 'no data'  unless repair.edrpou_spending_units
      repair.address = 'no address'             unless repair.address
      repair.amount = 0.0                       unless repair.amount

      repair.save()
      counter += 1
    end

    puts "#{counter} was changed"
  end

  desc 'Coordinates to float'
  task refactor_coordinates: :environment do
    # repairs = Repairing::Repair.where(coordinates: {:$type => 4}).to_a
    # repairs = Repairing::Repair.where(coordinates: {:$type => 1}).to_a
    counter = 0
    repairs = Repairing::Repair.all.each do |repair|

      # if repair.coordinates && !repair.coordinates[0].is_a?(Array)
      #   counter += 1
      #   puts " p_road(#{repair.coordinates}) "
      # end

      if repair.coordinates && repair.coordinates[0].is_a?(Array) && repair.coordinates[0].length != 1

        # --- road coordinates as string
        if  repair.coordinates.length == 2 && repair.coordinates[0][0].is_a?(String)
          # puts " ---p_road(#{repair.coordinates}) "
          # counter += 1
          # ------ to_f 364
        elsif repair.coordinates.length != 2 && repair.coordinates[0][0].is_a?(String)
          puts " p_road(#{repair.layer_id}) --- #{repair.address} --- #{repair.address_to}"
          puts " p_road(#{repair.coordinates}) "
          counter += 1
          # ------ to_f 3
        end

        # test = false
        # repair.coordinates.each do |r_road|
        #   # print " r_road("
        #   r_road.each do |p_road|
        #     # print " p_road(#{p_road}) "
        #     if p_road.is_a?(String)
        #       # puts " p_road(#{r_road}) "
        #       test = true
        #       next
        #     end
        #   end
        # print ") "

        # end
        # if test == true
        #   puts " p_road(#{repair.coordinates}) "
        #   counter += 1
        # end
        # puts ""
      elsif repair.coordinates && repair.coordinates[0].is_a?(Float) && repair.coordinates[1].is_a?(Float)
        # counter += 1
        # puts " p_road(#{repair.coordinates}) "
      elsif repair.coordinates && repair.coordinates[0].is_a?(Float) && !repair.coordinates[1].is_a?(Float)
        # counter += 1
        # puts " p_road(#{repair.coordinates}) "
      elsif repair.coordinates && repair.coordinates[0].is_a?(Array) && repair.coordinates[0].length == 1
        # puts " p_road(#{repair.coordinates}) --- #{repair.address} --- #{repair.address_to}"
        # counter += 1
        #----- not valid array 3
      elsif repair.coordinates && repair.coordinates[0].is_a?(String) && repair.coordinates[1].is_a?(String)
        # counter += 1
        # puts " point(#{repair.coordinates}) "
        #------ to_f 80
        # repair.coordinates.each do |r_point|
        #   # print " point(#{r_point}) "
        #   # puts " point(#{r_point}) "
        # end
      elsif !repair.coordinates
        # counter += 1
        # puts " error coordinates(#{repair.id}) "
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float) && repair.coordinates[0] == 0
        # counter += 1
        # puts " p_road(#{repair.coordinates}) "
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float) && repair.coordinates[0] == nil
        counter += 1
        # puts " p_road(#{repair.coordinates}) "
        # puts " p_road(#{repair.coordinates}) --- #{repair.address} --- #{repair.address_to}"
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float) && repair.coordinates.length == 3
        # counter += 1
        # puts " p_road(#{repair.coordinates}) "
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float)
        # counter += 1
        # puts " p_road(#{repair.coordinates}) "
      else
        # counter += 1
        # puts "#{repair.id} error coordinates: #{repair.coordinates}"
      end
      # puts ""
    end

    count = repairs.count()

    puts "count: #{count}"

    puts "counter: #{counter}"

  end
end