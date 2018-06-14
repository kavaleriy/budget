namespace :gmail_answer do
  desc "check answered appeals"
  task check_answers: :environment do
    Googles::Appeals.check_answers
  end
end
