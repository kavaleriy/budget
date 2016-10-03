namespace :modules_classifier_types do
  desc "Create types for classifier"
  task fill_types: :environment do
    Modules::ClassifierType.new(name: "Орган державної влади", code: 410).save
    Modules::ClassifierType.new(name: "Орган місцевого самоврядування", code: 420).save
    Modules::ClassifierType.new(name: "Державна організація", code: 425).save
    Modules::ClassifierType.new(name: "Комунальна організація", code: 430).save
    Modules::ClassifierType.new(name: "Інші організації", code: 440).save
    Modules::ClassifierType.new(name: "Філії", code: 610).save
  end

end
