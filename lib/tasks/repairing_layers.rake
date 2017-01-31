namespace :repairing_layers do
  desc "Add locale field with 'uk' value"
  task add_locale_field: :environment do
    Repairing::Layer.where(locale: nil).update_all(locale: 'uk')
  end

  desc "Add status field with 'plan' value"
  task add_status_field: :environment do
    Repairing::Layer.where(:status.ne => :fact).update_all(status: :plan)
  end

  desc "Add year field from repair_start_date value"
  task add_year_field: :environment do
    counter = 1
    Repairing::Layer.all.each do |layer|
      repair = Repairing::Repair.where(layer: layer.id, :repair_start_date.ne => nil).first()
      puts "#{counter} - #{repair.repair_start_date}" if repair
      puts "#{counter} - 0" unless repair

      # layer.year = repair.repair_start_date

      puts "layer.town - 0"                 unless layer.town
      puts "layer.owner - 0"                unless layer.owner
      puts "layer.repairing_category - 0"   unless layer.repairing_category
      puts "layer.title - 0"                unless layer.title
      puts "unless layer.status - 0"        unless layer.status

      # repair.save()
      # repairs = Repairing::Repair.where(layer: layer.id, :repair_start_date.ne => nil)
      # puts "#{counter} - #{repairs.count()}"
      #
      # repairs.each do |repair|
      #   puts "repair_data - #{repair.repair_start_date}"
      # end
      counter += 1
    end
  end
end