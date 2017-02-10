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
  task coordinate_to_float: :environment do
    # repairs = Repairing::Repair.where(coordinates: {:$type => 4}).to_a
    # repairs = Repairing::Repair.where(coordinates: {:$type => 1}).to_a
    counter = 0
    repairs = Repairing::Repair.any_of({coordinates: {:$type => 2}}, {coordinates: {:$type => 4}}).each do |repair|

      if repair.coordinates[0].is_a?(Array) && repair.coordinates[0].length != 1
        counter += 1
        if repair.coordinates.length != 2 || repair.coordinates[0].is_a?(String) || repair.coordinates[1].is_a?(String)
          puts " p_road(#{repair.coordinates}) "
        end
        repair.coordinates.each do |r_road|
          # print " r_road("
          r_road.each do |p_road|
            # print " p_road(#{p_road}) "
            if p_road.is_a?(String)
              # puts " p_road(#{r_road}) "
              next
            end
          end
          # print ") "

        end
        # puts ""
      elsif repair.coordinates[0].is_a?(Float) && repair.coordinates[1].is_a?(Float)
          counter += 1
          repair.coordinates.each do |r_point|
            # print " point(#{r_point}) "
            puts " point(#{r_point}) "
          end
      else
        # puts "error coordinates: #{repair.coordinates}"
      end
      # puts ""
    end

    count = repairs.count()

    puts "count: #{count}"

    puts "counter: #{counter}"

  end
end