namespace :create_admin do

  task create_admin: :environment do
    admin = User.new
    admin.name = 'Root'
    admin.email = 'root@admin.com'
    admin.town = 'Вінниця'
    admin.password = '1234'
    admin.password_confirmation = '1234'
    admin.roles = :admin

    admin.save

    admin.update_attribute(:locked,false)
  end

end