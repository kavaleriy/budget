namespace :resave_categories do
  task resave: :environment do
    records = Properting::Category.all
    records.to_a.each do |record|
      record.update!(title: record.title.mb_chars.downcase.to_s)
    end
    puts 'resave all items'
  end
end
