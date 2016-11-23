namespace :partners do

  task create_categories: :environment do
    Modules::PartnersCategory.create(title: 'Мапа', alias_str: 'map')
    Modules::PartnersCategory.create(title: 'Головна', alias_str: 'main')
    Modules::PartnersCategory.create(title: 'Календар', alias_str: 'calendar')
  end

  desc 'Set category to partners slides'
  task :set_category => :create_categories do
    main_cat = Modules::PartnersCategory.by_alias_str('main').first
    Modules::Partner.where(modules_partners_category_id: nil).each do |partner|
      partner.modules_partners_category = main_cat
      partner.save
    end
  end
end