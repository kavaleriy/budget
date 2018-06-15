# Learn more: http://github.com/javan/whenever

## for development
# set :environment, :development
# set :sh_path, '../gmail_secrets.sh'
## whenever --update-crontab --set environment='development'

## for production
set :sh_path, '/home/budget/www/gmail_secrets.sh'

set :output, 'log/whenever.log'
job_type :runner, "cd :path && source :sh_path && bin/rails runner -e :environment ':task' :output"

## example test in development
# every 1.minute do
#   runner "Googles::CheckAppealsAnswers.call"
# end

every :day, at: '11:50 pm' do
  runner "Googles::CheckAppealsAnswers.call"
end