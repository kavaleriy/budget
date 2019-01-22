# frozen_string_literal: true

namespace :users do
  desc 'create admin user'

  task init: :environment do
    binding.pry
    user = User.find_by_email('viktor1532@gmail.com')
    user.update(roles_mask: 1)

    puts 'user created'
  end
end
