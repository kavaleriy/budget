namespace :funds_managers do
  require 'external_api'

  desc 'Set title to funds_managers by edrpou'
  task set_titles: :environment do
    FundsManager.where(title: nil).each do |manager|
      edr_data_arr = ExternalApi.data_bot_edr(manager.edrpou) rescue {}
      unless edr_data_arr.blank?
        title = edr_data_arr.first['full_name']
        manager.title = title
        manager.save
      end
      puts manager.title
    end
  end
end