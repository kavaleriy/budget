# Learn more: http://github.com/javan/whenever

## for development
# set :environment, :development
# set :sh_path, '../gmail_secrets.sh'
## whenever --update-crontab --set environment='development'

## for production
set :sh_path, '/home/budget/www/gmail_secrets.sh'

set :output, 'log/whenever.log'
job_type :runner, "cd :path && source :sh_path && bin/rails runner -e :environment ':task' :output"
job_type :rake, 'cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output'

## example test in development
# every 1.minute do
#   runner "Googles::CheckAppealsAnswers.call"
# end

every :day, at: '11:50 pm' do
  runner "Googles::CheckAppealsAnswers.call"
end

# run every month at 1st day on 23:30
# every '30 23 1 * *' do
#   rake 'tmp:clear'
# end

# run every week on 00:30
every 1.week, at: '0:30 am' do
  rake 'tmp:clear'
end
