namespace :users do
  desc 'create admin user'

  task init: :environment do
    User.create!(name: 'Viktor', email: 'viktor1532@gmail.com', password: 'D3U2po', password_confirmation: 'D3U2po', roles_mask: 1, town_model: '559cec136b61730775040000')
    puts 'user created'
  end
end
