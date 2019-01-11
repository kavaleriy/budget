namespace :users do
  desc 'create admin user'

  task init: :environment do
    User.create!(name: 'admin', email: 'admin@admin.com', password: '1q2w3e', password_confirmation: '1q2w3e', roles_mask: 1, town_model: '559cec136b61730775040000')
    puts 'user created'
  end
end
