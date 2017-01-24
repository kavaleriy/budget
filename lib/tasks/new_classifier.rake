namespace :new_classifier do

  desc 'parse new classifier'
  task parse_new_classifier: :environment do
    file = File.open(Rails.root.join('db', 'classifiers', 'new_classffier.xlsx'))
    table = read_table_from_file(file.path)
    counter = 0
    types = Modules::ClassifierType.all_types
    table[:rows].each do |row|
      counter += 1 if Modules::Classifier.new.fill_params row, types
    end
    puts "All size #{table[:rows].size}"
    puts "#{counter} was parsed"
    puts "#{table[:rows].size - counter} was not parsed"
  end

end