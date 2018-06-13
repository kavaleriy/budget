namespace :gmail_answer do
  desc "TODO"
  task check_answers: :environment do
    appeals = Repairing::Appeal.approved.where(:answered.in => [nil, false])
    puts "appeals = #{appeals.size}"

    exit unless appeals.present?

    gmail = Gmail::GmailApi.new

    appeals.each do |appeal|
      email_info = gmail.email_info(appeal.account_number)

      next unless email_info[:messages_count]
      puts 'messages'
      puts email_info
      appeal.answered = true
      appeal.answered_date = email_info[:answered_date]
      appeal.save
    end
  end

end
