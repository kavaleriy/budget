namespace :change_data_field_to_string do
  desc 'change field data to string'

  # for now not need and newer used
  task change_to_string: :environment do
    require 'date'
    Repairing::Repair.all.no_timeout.each_with_index do |repair, index|
      repair.repair_start_date  = repair.repair_start_date.to_date.strftime("%d-%m-%Y") if repair.repair_start_date.present?
      repair.repair_end_date    = repair.repair_end_date.to_date.strftime("%d-%m-%Y")   if repair.repair_end_date.present?
      repair.save(validate: false)
      puts("#{index}")
    end
  end
end
