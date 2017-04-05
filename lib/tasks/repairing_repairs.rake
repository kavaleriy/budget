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
    deleted = 0
    @counter = 0

    def new_coordinates(repair)
      @counter += 1
      repair.coordinates = RepairingGeocoder.calc_coordinates(repair.address, repair.address_to)
      repair.save(validate: false)
    end

    repairs = Repairing::Repair.all.each do |repair|
      if repair.coordinates && repair.coordinates[0].is_a?(Array) && repair.coordinates[0].length != 1
        # --- road coordinates
      elsif repair.coordinates && repair.coordinates[0].is_a?(Float) && repair.coordinates[1].is_a?(Float)
        # valid coordinates
      elsif repair.coordinates && repair.coordinates[0].is_a?(Float) && !repair.coordinates[1].is_a?(Float)
        # !!!!!!!!! --------[50.944891, 0]----- --- м. Суми, провул. Громадянський,4а ------- # 36/1 on preprod/prod

        new_coordinates(repair)
      elsif repair.coordinates && repair.coordinates[0].is_a?(Array) && repair.coordinates[0].length == 1
        # !!!!!!!!!!!-----------([[4], [9]]) --- 3 --- 5 # 1/3 on preprod/prod

        @counter += 1
        repair.coordinates = nil
        repair.save(validate: false)
      elsif repair.coordinates && repair.coordinates[0].is_a?(String) && repair.coordinates[1].is_a?(String)
        # !!!!!!!!!!-----------["50.88917404890332", "33.50830078125"]--------- # 86/80 on preprod/prod

        @counter += 1
        repair.coordinates = repair.coordinates.map{|repair| repair.to_f}
        repair.save(validate: false)
      elsif !repair.coordinates && !repair.address
        # !!!!!!!!!!!!!!!!-----------()---   --   ---- # 96/96 on preprod/prod

        deleted += 1
        repair.destroy
      elsif !repair.coordinates
        # !!!!!!!!!!!!!!!!-----------()---different addresses------ # 153/151 on preprod/prod
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float) && repair.coordinates[0] == 0
        # !!!!!!!!!!!!!!!!-----------[0]---м.Конотоп, пр-т Миру,8 --- м.Конотоп, вул.Сарнавська, 38а------ # 22/22 on preprod/prod

        new_coordinates(repair)
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float) && repair.coordinates[0] == nil
        # !!!!!!!!!!!!!!!!-----------[nil, [51.25868579999999, 33.1998598]]----- --- () --- (м.Конотоп, вул.Успенсько-Троїцька,61)------ # 32/32 on preprod/prod

        new_coordinates(repair)
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float) && repair.coordinates.length == 3
        # !!!!!!!!!!!!!!!---------[48, 429492, 35.002657]-------- м.Дніпропетровськ, вул. Суворова 11 ------ # 1/1 on preprod/prod

        new_coordinates(repair)
      elsif repair.coordinates && !repair.coordinates[0].is_a?(Float)
        # !!!!!!!!!!!!!!!---------([44])---([22, 22]) ----------  м.Суми, вул.Кооперативна,4 --- м.Контоп, вул.Усп.Троїцька,58 ------ # 15/15 on preprod/prod

        new_coordinates(repair)
      else
        # ------ # 0/0 on preprod/prod
      end
    end

    count = repairs.count()

    puts "changed:  #{@counter}"
    puts "count:    #{count + deleted}"
    puts "deleted:  #{deleted}"
    puts "remained: #{count}"

  end
end