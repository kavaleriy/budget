namespace :create_test_town do
  desc "Create test town"

  task remove_old_test_town: :environment do
    test_towns = Town.get_test_town
    test_towns.each { |town| town.destroy }
  end

  task create_test_town_task: :remove_old_test_town do
    test_town = Town.new({title: 'Test' ,level: '3',description: 'Test town'})
    test_town.save
  end

  desc "Create calendar for test town"
  task create_test_calendar_task: :create_test_town_task do
    test_town = Town.get_test_town.first
    test_calendar = Calendar.new({town: test_town.title ,author: 'test@gmail.com',title: 'Демонстрація типового календаря',
                                  description: 'Демонстрація типового календаря',is_test: true})
    test_calendar.save
  end

  desc "Create taxonomy rot and taxonomy rov for test town"
  task create_test_taxonomy_task: :create_test_calendar_task do
    test_town = Town.get_test_town.first
    test_taxonomy_rot = TaxonomyRot.new({title: 'test',name: 'test',description: 'test', owner: test_town.title})
    test_taxonomy_rot.save
    test_taxonomy_rov = TaxonomyRov.new({title: 'test',name: 'test',description: 'test', owner: test_town.title})
    test_taxonomy_rov.save
  end

  desc "Create indicate taxonomy for test town"
  task create_indicate_taxonomy_task: :create_test_taxonomy_task do
    test_town = Town.get_test_town.first
    test_indicate = Indicate::Taxonomy.new(town_id: test_town['_id'])
    test_indicate.save
  end

  desc "Create test town data"
  task create_test_town: :create_indicate_taxonomy_task do

  end

end
