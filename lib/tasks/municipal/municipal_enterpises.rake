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

  desc "delete code statuses without code description"
  task delete_statuses: :environment do
    require 'status_code/set_status'

    statuses = Municipal::CodeStatus.all
    statuses.each_with_index do |status, i|
      unless StatusCode::SetStatus.code_desc_exists?(status.code)
        p "#{i} - #{status.code} - #{status.title}"
        status.destroy
      end
    end
  end

  desc "set statuses for last files from 2018-10-08 to 2018-10-21"
  task add_statuses: :environment do
    start_date = Date.parse('2018-10-08').beginning_of_day
    end_date = Date.parse('2018-10-21').end_of_day
    files = Municipal::EnterpriseFile.where(created_at: start_date..end_date).uniq(&:enterprise_id)

    files.each_with_index do |file, i|
      p "##{i} -#{file.file_type} - #{file.year} - #{file.enterprise.town.title} - #{file.enterprise.title}"
      StatusCode::SetStatus.enterprise(file.enterprise)
    end
  end

end
