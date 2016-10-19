class ExternalApi

  # http://localhost:3000/external_api/edata?payer_edrpous=39883094&recipt_edrpous=09334702&format=json

  def self.e_data_payments(payer_erdpou, recipt_edrpou, start_date = Time.now.months_since(-1).strftime("%d-%m-%Y"), end_date = Time.now.strftime("%d-%m-%Y"))
    start_date = start_date || Time.now.months_since(-3).strftime("%d-%m-%Y")
    end_date = end_date || Time.now.strftime("%d-%m-%Y")
    data = self.params(payer_erdpou, recipt_edrpou, start_date, end_date)

    uri = URI.parse('http://api.e-data.gov.ua:8080/api/rest/1.0/transactions')
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

    data.group_by{ |hash| hash['recipt_edrpou'] }.each do |recipt_edrpou, payment|
      most_received << {
          name: payment.first['recipt_name'],
          val: payment.inject(0) { |sum, item| sum += item['amount'].to_f }
      }
    end

    most_received.sort_by! { |hash| hash[:val] }.reverse!
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