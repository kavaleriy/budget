namespace :modules_classifier_types do
  desc "Create types for classifier"
  task fill_types: :environment do
    Modules::ClassifierType.new(name: "Орган державної влади", code: [410], payer: true, receipt: true).save
    Modules::ClassifierType.new(name: "Орган місцевого самоврядування", code: [420], payer: true, receipt: true).save
    Modules::ClassifierType.new(name: "Державна організація", code: [425], payer: true, receipt: true).save
    Modules::ClassifierType.new(name: "Комунальна організація", code: [430], payer: true, receipt: true).save
    Modules::ClassifierType.new(name: "Інші організації", code: [440, 510, 590], payer: true, receipt: false).save
    Modules::ClassifierType.new(name: "Філії", code: [610], payer: true, receipt: false).save
    Modules::ClassifierType.new(name: "Фермерське господарство", code: [110], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Приватне підприємство", code: [120], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Колективне підприємство", code: [130], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Державне підприємство", code: [140], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Комунальне підприємство", code: [150], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Дочірнє підприємство", code: [160], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Об’єднання громадян", code: [180, 185, 190, 191], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Товариства відкриті, закриті, з обмеженою відповідальністю",
                                code: [230, 231, 240, 250, 270], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Кооперативи", code: [310, 320, 321, 330, 340, 350], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Інші установи та заклади", code: [440, 590, 610], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Громадські організації", code: [810, 815], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Спілки та інші об’єднання",
                                code: [820, 825, 830, 840, 845, 855, 930, 935, 995], payer: false, receipt: true).save
    Modules::ClassifierType.new(name: "Органи самоорганізації населення", code: [860], payer: false, receipt: true).save
  end

  desc "Delete types for classifier"
  task del_types: :environment do
    Modules::ClassifierType.delete_all
  end


end
