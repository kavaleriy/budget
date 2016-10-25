namespace :partners do
  desc 'Set category to partners slides'

  task :set_category => :environment do
    Modules::Partner.where(category: nil).each do |t|
      t.update_attribute :category, I18n.t('tasks.partners.main_page')
    end
  end
end