# frozen_string_literal: true

namespace :town do
  desc 'rename town'
  task rename_city: :environment do
    town = Town.find_by(title: 'Мукачеве')
    town.title = 'Мукачево'
    town.save
    puts 'City was renamed!'
  end
end
