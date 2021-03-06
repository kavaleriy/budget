# frozen_string_literal: true

namespace :users do
  desc 'create admin user'

  task init: :environment do
    user = User.find_by_email('valentin.poteruxa@gmail.com')
    user.update(roles_mask: 1)

    puts 'user updated'
  end
end
