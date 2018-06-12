namespace :gmail_answer do
  desc "TODO"
  task check_answers: :environment do
    # appeals = Repairing::Appeal.approved.where(answered: false)
    # appeals = Repairing::Appeal.where(_status: :approved)
    appeals = Repairing::Appeal.approved.where(:answered.in => [nil, false])
    puts appeals.size
    appeals.each do |appeal|
      # @message = GmailApi.new(appeal.account_number)
      # binding.pry

      messages = GmailApi.messages(appeal.account_number)
      puts "gim - #{appeal.account_number}"

      if messages
        puts 'messages'
        puts messages
        # appeal.answered = true
        # appeal.answered_date = Time.now
        # appeal.save
      end
      # check if exists
      # save answered: true, date: today(Time.now)


      # @file_test = @file.new_file
      # @repairing_appeal.answer_file = @file.new_file
      # @repairing_appeal.answer_text = @file.text
    end
  end

end
