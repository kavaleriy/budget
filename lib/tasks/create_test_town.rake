namespace :create_test_town do
  desc "Create test town"
  task create_test_town_task: :environment do
    test_town = Town.new({title: 'test',description: 'Test town'})
    test_town.save
  end

  desc "Create calendar for test town"
  task create_test_calendar_task: :environment do
    test_calendar = Calendar.new({town: 'test',author: 'test',title: 'test',description: 'test'})
    test_calendar.save
  end

  desc "Create taxonomy rot and taxonomy rov for test town"
  task create_test_taxonomy_task: :environment do
    test_town = Town.get_test_town.to_a
    TaxonomyRot.where(title: 'test').destroy
    test_taxonomy_rot = TaxonomyRot.new({title: 'test',name: 'test',description: 'test', owner: test_town[0]})
    test_taxonomy_rot.save
    test_taxonomy_rov = TaxonomyRov.new({title: 'test',name: 'test',description: 'test', owner: test_town[0]})
    test_taxonomy_rov.save
  end

  desc "Create indicate taxonomy for test town"
  task create_indicate_taxonomy_task: :environment do
    test_town = Town.get_test_town.to_a
    test_indicate = Indicate::Taxonomy.new(town_id: test_town[0]['_id'])
    test_indicate.save
  end


end
