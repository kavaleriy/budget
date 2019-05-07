# frozen_string_literal: true

namespace :town do
  desc 'rename town'
  task rename_city: :environment do
    town = Town.find_by(title: 'Мукачеве')
    town.title = 'Мукачево'
    town.save
    puts 'City was renamed!'
  end
  task rename_city_2: :environment do
    town = Town.find_by(title: 'Новгород-сіверський')
    town.title = 'Новгород-Сіверський'
    town.save
    puts 'City was renamed!'
  end
end
