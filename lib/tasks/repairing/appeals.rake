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

  desc "add town_id to appeals"
  task add_town: :environment do
    Repairing::Appeal.where(town: nil).each do |appeal|
      appeal.town = appeal.repair.layer.town
      appeal.save
      p "Appeal - #{appeal.account_number}"
    end
  end

end
