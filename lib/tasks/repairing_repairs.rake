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
end