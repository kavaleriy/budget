namespace :appeals do
  desc "set acount number"
  task set_acount_number: :environment do
    Repairing::Appeal.order(created_at: :asc).each do |appeal|
      appeal.set_account_number
      appeal.save
      p "Account number #{appeal.account_number} for #{appeal.email}."
    end
  end

  desc "check answered appeals"
  task check_answers: :environment do
    Googles::CheckAppealsAnswers.call
  end

end
