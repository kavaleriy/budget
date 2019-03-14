namespace :properting_properties do
  desc 'Set start_date'
  task set_start_date: :environment do
    counter = 0
    old_date_properties = Properting::Property.where(:property_date.exists => true, :property_date.ne => nil, :property_start_date.exists => false)
    puts "#{old_date_properties.count} properties selected"

    old_date_properties.each do |property|
      if property.coordinates.blank?
        puts "#{counter} not changed, property_id - #{property.id}, layer_id - #{property.layer_id}"
        next
      end

      property.property_start_date = property.property_date

      # property.spending_units = 'no data'         unless property.spending_units
      # property.edrpou_spending_units = 'no data'  unless property.edrpou_spending_units
      property.address = 'no address'             unless property.address
      property.amount = 0.0                       unless property.amount

      property.save()
      counter += 1
    end

    puts "#{counter} was changed"
  end

  desc 'Refactor coordinates'
  task refactor_coordinates: :environment do
    deleted = 0
    @counter = 0

    def new_coordinates(property)
      @counter += 1
      property.coordinates = RepairingGeocoder.calc_coordinates(property.address, property.address_to)
      property.save(validate: false)
    end

    properties = Properting::Property.all.each do |property|
      if property.coordinates && property.coordinates[0].is_a?(Array) && property.coordinates[0].length != 1
        # --- road coordinates
      elsif property.coordinates && property.coordinates[0].is_a?(Float) && property.coordinates[1].is_a?(Float)
        # valid coordinates
      elsif property.coordinates && property.coordinates[0].is_a?(Float) && !property.coordinates[1].is_a?(Float)
        # !!!!!!!!! --------[50.944891, 0]----- --- м. Суми, провул. Громадянський,4а ------- # 36/1 on preprod/prod

        new_coordinates(property)
      elsif property.coordinates && property.coordinates[0].is_a?(Array) && property.coordinates[0].length == 1
        # !!!!!!!!!!!-----------([[4], [9]]) --- 3 --- 5 # 1/3 on preprod/prod

        @counter += 1
        property.coordinates = nil
        property.save(validate: false)
      elsif property.coordinates && property.coordinates[0].is_a?(String) && property.coordinates[1].is_a?(String)
        # !!!!!!!!!!-----------["50.88917404890332", "33.50830078125"]--------- # 86/80 on preprod/prod

        @counter += 1
        property.coordinates = property.coordinates.map{|property| property.to_f}
        property.save(validate: false)
      elsif !property.coordinates && !property.address
        # !!!!!!!!!!!!!!!!-----------()---   --   ---- # 96/96 on preprod/prod

        deleted += 1
        property.destroy
      elsif !property.coordinates
        # !!!!!!!!!!!!!!!!-----------()---different addresses------ # 153/151 on preprod/prod
      elsif property.coordinates && !property.coordinates[0].is_a?(Float) && property.coordinates[0] == 0
        # !!!!!!!!!!!!!!!!-----------[0]---м.Конотоп, пр-т Миру,8 --- м.Конотоп, вул.Сарнавська, 38а------ # 22/22 on preprod/prod

        new_coordinates(property)
      elsif property.coordinates && !property.coordinates[0].is_a?(Float) && property.coordinates[0] == nil
        # !!!!!!!!!!!!!!!!-----------[nil, [51.25868579999999, 33.1998598]]----- --- () --- (м.Конотоп, вул.Успенсько-Троїцька,61)------ # 32/32 on preprod/prod

        new_coordinates(property)
      elsif property.coordinates && !property.coordinates[0].is_a?(Float) && property.coordinates.length == 3
        # !!!!!!!!!!!!!!!---------[48, 429492, 35.002657]-------- м.Дніпропетровськ, вул. Суворова 11 ------ # 1/1 on preprod/prod

        new_coordinates(property)
      elsif property.coordinates && !property.coordinates[0].is_a?(Float)
        # !!!!!!!!!!!!!!!---------([44])---([22, 22]) ----------  м.Суми, вул.Кооперативна,4 --- м.Контоп, вул.Усп.Троїцька,58 ------ # 15/15 on preprod/prod

        new_coordinates(property)
      else
        # ------ # 0/0 on preprod/prod
      end
    end

    count = properties.count()

    puts "changed:  #{@counter}"
    puts "count:    #{count + deleted}"
    puts "deleted:  #{deleted}"
    puts "remained: #{count}"
  end
end
