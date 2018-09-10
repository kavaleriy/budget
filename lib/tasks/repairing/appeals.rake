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

  desc "change town emails title"
  task change_town_emails_title: :environment do
    owners_aliases = %w[city_council local_deputy peoples_deputy state_audit_office]

    owners_aliases.each do |owner|
      TownEmail.where(owner: owner).update_all(owner: I18n.t("mongoid.attributes.town.#{owner}"))
    end
    p "Changed alias owner to title."
  end
end
