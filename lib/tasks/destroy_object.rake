namespace :destroy_object do
  desc "Destroy town"
  task :town, [:town_id] => :environment do |_, args|
    town = Town.find(args[:town_id])
    puts "#{town} destroyed!" if town.destroy
  end
end