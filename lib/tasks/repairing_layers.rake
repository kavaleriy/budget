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
    layers = Repairing::Layer.all
    puts "Layers - #{layers.count}"
    layers.each do |layer|
      repair = layer.repairs.where(:repair_start_date.ne => nil).first()

      layer.year = repair.repair_start_date.year if repair
      layer.status = :plan if layer.status.blank?
      layer.title = "Default title" if layer.title.blank?

      layer.save
    end
  end
end