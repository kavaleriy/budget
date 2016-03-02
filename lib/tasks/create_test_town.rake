namespace :create_test_town do
  desc "Create test town"
  task create_task: :environment do
    test_town = Town.new({title: 'test',description: 'Test town'})
    test_town.save
  end
end
