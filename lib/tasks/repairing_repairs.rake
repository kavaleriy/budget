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
          # ---------  string coordinates point
          # puts " ---p_road(#{repair.coordinates}) "
          # counter += 1
          # ------ to_f 364
        elsif repair.coordinates.length != 2 && repair.coordinates[0][0].is_a?(String)
          # ---------  string coordinates road
          # puts " p_road(#{repair.layer_id}) --- #{repair.address} --- #{repair.address_to}"
          # puts " p_road(#{repair.coordinates}) "
          # counter += 1
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
        # valid coordinates
        # counter += 1
        # puts " p_road(#{repair.coordinates}) "
      elsif repair.coordinates && repair.coordinates[0].is_a?(Float) && !repair.coordinates[1].is_a?(Float)
        # !!!!!!!!! ------------------[50.944891, 0]----- --- м. Суми, провул. Громадянський,4а --- ----------------- # 36 on preprod
        # counter += 1
        # puts " p_road(#{repair.layer_id}) --- #{repair.address} --- #{repair.address_to}"
        # puts " p_road(#{repair.coordinates}) "
      elsif repair.coordinates && repair.coordinates[0].is_a?(Array) && repair.coordinates[0].length == 1
        # !!!!!!!!!!!!!!!!-----------([[4], [9]]) --- 3 --- 5 # 1 on preprod
        # puts " p_road(#{repair.coordinates}) --- #{repair.address} --- #{repair.address_to}"
        # counter += 1
        #----- not valid array 3
      elsif repair.coordinates && repair.coordinates[0].is_a?(String) && repair.coordinates[1].is_a?(String)
        # !!!!!!!!!!!!!!!!-----------["50.88917404890332", "33.50830078125"]--------- # 86 on preprod
        # counter += 1
        # puts " point(#{repair.coordinates}) "
        #------ to_f 80
        # repair.coordinates.each do |r_point|
        #   # print " point(#{r_point}) "
        #   # puts " point(#{r_point}) "
        # end
      elsif !repair.coordinates
        # !!!!!!!!!!!!!!!!-----------()---different addresses------ # 249 on preprod
        # counter += 1
        # puts " p_road(#{repair.layer_id}) --- #{repair.address} --- #{repair.address_to}"
        # puts " coordinates(#{repair.coordinates}) "
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float) && repair.coordinates[0] == 0
        # !!!!!!!!!!!!!!!!-----------[0]---м.Конотоп, пр-т Миру,8 --- м.Конотоп, вул.Сарнавська, 38а------ # 22 on preprod
        # counter += 1
        # puts " p_road(#{repair.layer_id}) --- #{repair.address} --- #{repair.address_to}"
        # puts " coordinates(#{repair.coordinates}) "
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float) && repair.coordinates[0] == nil
        # !!!!!!!!!!!!!!!!-----------[nil, [51.25868579999999, 33.1998598]]----- --- () --- (м.Конотоп, вул.Успенсько-Троїцька,61)------ # 32 on preprod
        # counter += 1
        # puts " p_road(#{repair.layer_id}) --- #{repair.address} --- #{repair.address_to}"
        # puts " coordinates (#{repair.coordinates}) "
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float) && repair.coordinates.length == 3
        # !!!!!!!!!!!!!!!---------[48, 429492, 35.002657]-------- м.Дніпропетровськ, вул. Суворова 11 ------ # 1 on preprod
        # counter += 1
        # puts " p_road(#{repair.layer_id}) --- #{repair.address} --- #{repair.address_to}"
        # puts " p_road(#{repair.coordinates}) "
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float)
        # !!!!!!!!!!!!!!!---------([44])---([22, 22]) ----------  м.Суми, вул.Кооперативна,4 --- м.Контоп, вул.Усп.Троїцька,58 ------ # 15 on preprod
        # counter += 1
        # puts " p_road(#{repair.layer_id}) --- #{repair.address} --- #{repair.address_to}"
        # puts " coordinates (#{repair.coordinates}) "
      else
        # ------ # 0 on preprod
        # counter += 1
        # puts " p_road(#{repair.layer_id}) --- #{repair.address} --- #{repair.address_to}"
        # puts " coordinates: #{repair.coordinates}"
      end
      # puts ""
    end

    count = repairs.count()

    puts "count: #{count}"

    puts "counter: #{counter}"

  end
end