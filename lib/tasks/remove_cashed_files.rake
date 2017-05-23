namespace :remove_cashed_files do

  desc "Remove CarrierWave cached files"
  task carrierwave: :environment do
    CarrierWave.clean_cached_files!
  end

end