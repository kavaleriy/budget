class ExternalApi

  # http://localhost:3000/external_api/edata?payer_edrpous=39883094&recipt_edrpous=09334702&format=json

  def self.dani_mist_data(path)
    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.path)
    http.use_ssl = (uri.scheme == "https")

    http.request(request).body rescue {}
  end

  def self.e_data_payments(payer_erdpou, recipt_edrpou, start_date, end_date)
    if start_date.blank? && end_date.blank?
      # get transactions by 91 day from 2016-01-01
      transactions = []
      today = Date.today
      first_date = '2015-12-31'.to_date
      dates = [today]

      while first_date < dates.last
        dates << dates.last.days_since(-90)
        request = e_data_payments_request(payer_erdpou, recipt_edrpou, dates.last.days_since(1), dates[-2])
        transactions += request if request.present?
      end
    else
      transactions = e_data_payments_request(payer_erdpou, recipt_edrpou, start_date, end_date)
    end
    transactions
  end

  def self.e_data_payments_request(payer_erdpou, recipt_edrpou, start_date = nil, end_date = nil)
    require 'net/http'
    start_date ||= default_start_date
    end_date ||= default_end_date
    # https://confluence.spending.gov.ua/pages/viewpage.action?pageId=5800614
    # https://ruby-doc.org/stdlib-2.2.1/libdoc/net/http/rdoc/Net/HTTP.html

    # # # OLd
    # uri = URI.parse('http://api.spending.gov.ua/api/v2/api/transactions/')
    #
    # params = params(payer_erdpou, recipt_edrpou, start_date, end_date)
    # uri.query = URI.encode_www_form(params)
    #
    # res = Net::HTTP.get_response(uri)
    # # puts res.body if res.is_a?(Net::HTTPSuccess)
    #
    # JSON.parse(res.body)

    # # # New
    url = URI.parse('http://api.spending.gov.ua/api/v2/api/transactions/')

    params = params(payer_erdpou, recipt_edrpou, start_date, end_date)
    url.query = URI.encode_www_form(params)

    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Get.new(url.request_uri, { 'Content-Type' => 'application/json' })

    tries ||= 3
    p "try # #{tries}"
    res = http.request(req)
  # Retry query 3 times to api if SocketError
  rescue SocketError => e
    retry unless (tries -= 1).zero?
  else
    # puts(res.body)
    JSON.parse(res.body)
  end

  def self.data_bot_edr(erdpou)
    uri = URI.encode("https://opendatabot.com/api/v2/company/#{erdpou}?apiKey=#{ENV['OPEN_DATA_BOT_API_KEY']}")
    get_request(uri)
  end

  def self.data_bot_decisions(erdpou)
    # encode_url = URI.encode("https://opendatabot.com/api/v1/fullcompany/#{erdpou}?apiKey=#{ENV['OPEN_DATA_BOT_API_KEY']}")
    # encode_url = URI.encode("https://opendatabot.com/api/v2/company/39043167?apiKey=#{ENV['OPEN_DATA_BOT_API_KEY']}")
    # test request by edrpou without decisions (40796115)
    # encode_url = URI.encode("https://opendatabot.com/api/v1/fullcompany/39043167?apiKey=#{ENV['OPEN_DATA_BOT_API_KEY']}")

    uri = URI.encode("http://court.opendatabot.com/api/v1/court?text=#{erdpou}&limit=500&apiKey=#{ENV['OPEN_DATA_BOT_API_KEY']}")
    get_request(uri)
  end

  def self.most_received(payer_erdpou, recipt_edrpou, start_date = nil, end_date = nil)
    start_date ||= default_start_date
    end_date ||= default_end_date
    most_received = []
    data = self.e_data_payments(payer_erdpou, recipt_edrpou, start_date, end_date)

    role = (payer_erdpou.blank? and not recipt_edrpou.blank?) ? 'payer' : 'recipt'
    data.group_by{ |hash| hash["#{role}_edrpou"] }.each do |edrpou, payment|
      if edrpou.to_i.eql?(0)
        payment.group_by{ |hash| hash["#{role}_name"] }.each do |entrepreneur, pay|
          most_received << {
              name: entrepreneur,
              edrpou: 'xxxxxxxxxx',
              val: pay.inject(0) { |sum, item| sum += item['amount'].to_f }
          }
        end
      else
        most_received << {
            name: payment.first["#{role}_name"],
            edrpou: payment.first["#{role}_edrpou"],
            val: payment.inject(0) { |sum, item| sum += item['amount'].to_f }
        }
      end
    end

    most_received.sort_by! { |hash| hash[:val] }.reverse!
  end

  #  TODO: del in feature 'http://edr.data-gov-ua.org/api'
  # because 28.03.2018 this api was not working
  # and now not used in this app
  def self.edr_data(company_edrpou)
    unless company_edrpou.nil?
      uri = URI.parse("http://edr.data-gov-ua.org/api/companies?where={\"edrpou\":{\"contains\":\"#{company_edrpou}\"}}&limit=1")

      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Get.new(uri.request_uri, {'Content-Type' =>'application/json'})

      JSON.parse(http.request(request).body)
    end
  end

  def self.prozzoro_data(id)
    unless id.nil?
      uri = URI("https://lb.api.openprocurement.org/api/0/tenders/#{id}")

      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Get.new(uri.request_uri, {'Content-Type' =>'application/json'})
      http.use_ssl = (uri.scheme == "https")
      JSON.parse(http.request(request).body)['data'] rescue nil
    end
  end

  class << self
    private

    def get_request(uri)
      require 'net/http'

      url = URI.parse(uri)

      req = Net::HTTP::Patch.new(url.to_s, 'Content-Type' => 'application/json')
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == 'https'
      res = http.start do |http|
        http.request(req)
      end

      JSON.parse(res.body)
    end

    def default_start_date
      # because {"errorMessage"=>"Перевищено максимальний діапозон дат пошуку, 92 дні"} - 06.06.2018
      Time.now.days_since(-91).strftime('%Y-%m-%d')
    end

    def default_end_date
      Time.now.strftime('%Y-%m-%d')
    end

    def params(payer_erdpou, recipt_edrpou, start_date, end_date)
      data = {
        startdate: start_date,
        enddate: end_date
      }

      data['payers_edrpous'] = payer_erdpou
      data['recipt_edrpous'] = recipt_edrpou

      data.delete_if { |_key, value| value.blank? }
    end
  end

end