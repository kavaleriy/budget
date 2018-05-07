namespace :appeals do

  desc "set acount number"
  task set_acount_number: :environment do
    Repairing::Appeal.by_create.each do |appeal|
      appeal.set_account_number
      appeal.save
      p "Account number #{appeal.account_number} for #{appeal.email}."
    end
  end
end