namespace :enterprises do
  desc "set enterprises statuses"
  task set_statuses: :environment do
    StatusCode::SetStatus.all_enterprises
  end

  desc "correct edrpou"
  task correct_edrpou: :environment do
    include Repairing::RepairsHelper

    enterprises = Municipal::Enterprise.where('this.edrpou.length >= 4 && this.edrpou.length <= 7')
    enterprises.each do |enterprise|
      p enterprise.edrpou
      enterprise.edrpou = correct_edrpou(enterprise.edrpou)
      enterprise.save
    end
  end

  desc "set checked yourscore"
  task set_checked: :environment do
    enterprises = Municipal::Enterprise.all
    enterprises.each do |enterprise|
      enterprise.debt_checked = Time.now
      enterprise.scores_checked = Time.now
      enterprise.save
    end
  end
end