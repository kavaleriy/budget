class ExternalApi

  # http://localhost:3000/external_api/edata?payer_edrpous=39883094&recipt_edrpous=09334702&format=json

  def self.dani_mist_data(path)
    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.path)
    http.use_ssl = (uri.scheme == "https")

    http.request(request).body rescue {}
  end

  def self.e_data_payments(payer_erdpou, recipt_edrpou, start_date = Time.now.months_since(-3).strftime("%d-%m-%Y"), end_date = Time.now.strftime("%d-%m-%Y"))
    start_date = start_date || Time.now.months_since(-3).strftime("%d-%m-%Y")
    end_date = end_date || Time.now.strftime("%d-%m-%Y")

    # https://confluence.spending.gov.ua/pages/viewpage.action?pageId=5800614
    # edrpous from this http://api.spending.gov.ua/api/v2/api/transactions/top100
    # payer_erdpou = "37567646"
    # recipt_edrpou = "00013480"
    data = self.params(payer_erdpou, recipt_edrpou, start_date, end_date)

    uri = URI.parse('http://api.e-data.gov.ua:8080/api/rest/1.0/transactions')
    # uri = URI.parse('http://api.e-data.gov.ua:8080/api/v2/api/transactions')
    # uri = URI.parse('http://api.spending.gov.ua/api/v2/api/transactions')
    # uri = URI.parse('http://api.spending.gov.ua/api/rest/1.0/transactions')

    # binding.pry

    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
    request.body = data.to_json

    JSON.parse(http.request(request).body)['response']['transactions'] rescue {}
  end

  def self.most_received(payer_erdpou, recipt_edrpou, start_date = Time.now.months_since(-3).strftime("%d-%m-%Y"), end_date = Time.now.strftime("%d-%m-%Y"))
    start_date = start_date || Time.now.months_since(-3).strftime("%d-%m-%Y")
    end_date = end_date || Time.now.strftime("%d-%m-%Y")
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

  private
  def self.params(payer_erdpou, recipt_edrpou, start_date, end_date)
    data = {
        'startdate' => start_date,
        'enddate' => end_date
    }

    data['payers_edrpous'] = payer_erdpou
    data['recipt_edrpous'] = recipt_edrpou

    data.delete_if { |key, value| value.blank? }
  end


end