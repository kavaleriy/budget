namespace :repairing_layers do
  desc "Add locale field with 'uk' value"
  task add_locale_field: :environment do
    Repairing::Layer.where(locale: nil).update_all(locale: 'uk')
  end

  desc "Add status field with 'plan' value"
  task add_status_field: :environment do
    Repairing::Layer.where(:status.ne => :fact).update_all(status: :plan)
  end
end