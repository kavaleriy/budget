namespace :repairing_repairs do
  desc 'Set start_date'
  task set_start_date: :environment do
    counter = 0
    old_date_repairs = Repairing::Repair.where(:repair_date.exists => true, :repair_date.ne => nil, :repair_start_date.exists => false)
    puts "#{old_date_repairs.count} repairs selected"

    old_date_repairs.each do |repair|
      if repair.coordinates.blank?
        puts "#{counter} not changed, repair_id - #{repair.id}, layer_id - #{repair.layer_id} - coordinates blank"
        next
      end

      repair.repair_start_date = repair.repair_date
      repair.save(validate: false)
      counter += 1
    end

    puts "#{old_date_repairs.count} was not changed"
    puts "#{counter} was changed"
  end
end