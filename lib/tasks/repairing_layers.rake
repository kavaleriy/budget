namespace :repairing_layers do
  desc "Add locale field with 'uk' value"
  task add_locale_field: :environment do
    Repairing::Layer.where(locale: nil).update_all(locale: 'uk')
  end
end