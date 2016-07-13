namespace :create_admin do

  task create_admin: :environment do
    admin = User.find_by_email('root@admin.com').first
    admin.roles = :admin
    admin.locked = false

    admin.save
  end

end