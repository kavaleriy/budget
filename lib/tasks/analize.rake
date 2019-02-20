namespace :budget_files do
  require 'net/http'

  task send_request: :environment do
    path = 'http://api.spending.gov.ua/api/v2/api/transactions/'
    erdpou = '24899941'
    startdate = '2018-11-22'
    enddate = '2019-02-20'
    call(path, startdate, enddate, erdpou)
  end
  
  def call(path, startdate, enddate, erdpou)
    binding.pry
    uri = URI(path)
    params = { startdate: startdate,
               enddate: enddate,
               payers_edrpous: erdpou }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    binding.pry
    JSON.parse(res.body)
  end
end
