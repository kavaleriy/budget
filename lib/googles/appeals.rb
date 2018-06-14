module Googles
  class Appeals
    def self.check_answers
      appeals = Repairing::Appeal.approved.where(:answered.in => [nil, false])
      puts "appeals - #{appeals.size}, #{Time.now}"

      exit unless appeals.present?

      gmail = Googles::GmailApi.new

      appeals.each do |appeal|
        email_info = gmail.email_info(appeal.account_number)

        next unless email_info[:messages_count]
        puts "appeal_number - #{appeal.account_number}"
        puts email_info
        appeal.answered = true
        appeal.answered_date = email_info[:answered_date]
        appeal.save
      end
    end
  end
end