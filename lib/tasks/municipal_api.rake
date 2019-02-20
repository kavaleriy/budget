namespace :municipal_api do
  require 'net/http'

  task send_request: :environment do
    path = 'http://api.spending.gov.ua/api/v2/api/transactions/'
    codes = ['24899941', '00013480', '02143264', '13576948']
    startdate = '2018-11-22'
    enddate = '2019-02-20'

    codes.each do |erdpou|
      call(path, startdate, enddate, erdpou)
    end
  end

  def call(path, startdate, enddate, erdpou)
    uri = URI(path)
    params = { startdate: startdate,
               enddate: enddate,
               payers_edrpous: erdpou }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    json = JSON.parse(res.body)

    bad_request = 0

    json.each_with_index do |data, index|
      arr = []

      arr << data['payer_name'] if data['payer_name'].present?
      arr << data['payer_edrpou'] if data['payer_edrpou'].present?
      arr << data['payment_details'] if data['payment_details'].present?
      arr << data['payer_bank'] if data['payer_bank'].present?
      arr << data['recipt_edrpou'] if data['recipt_name'].present?
      arr << data['recipt_name'] if data['recipt_name'].present?

      if data['payment_details'].present? && data['recipt_edrpou'].present?
        if data['payment_details'].include?('xx') || data['recipt_edrpou'].include?('xx')
          bad_request = bad_request + 1
        end
      end
      write_data(arr, (index+1))
    end
    persent(json.count, bad_request)
  end

  def persent(all_count, bad)
    x = ((100 * bad) / all_count)
    open('analize.txt', 'a') do |f|
      f.puts "\n\n" + 'Ввсього записів: ' + all_count.to_s + "\n"
      f.puts 'Зашифрованих: ' + bad.to_s + "\n"
      f.puts 'Відсоток зашифрованих: ' + x.to_s + "\n"
      f.puts '**********************************************************************************************************' + "\n\n\n\n\n\n"
    end
  end

  def write_data(arr, i)
    open('analize.txt', 'a') do |f|
      arr.each_with_index do |data, index|
        case index
          when 0
            f.puts i.to_s + ') ' + 'Назва платника: ' + data + "\n"
          when 1
            f.puts 'ЄРДПОУ платника: ' + data + "\n"
          when 2
            f.puts 'Деталі оплати: ' + data + "\n"
          when 3
            f.puts 'Банк платника: ' + data + "\n"
          when 4
            f.puts 'ЄРДПОУ отримувача: ' + data + "\n"
          when 5
            f.puts 'Назва отримувача: ' + data + "\n\n"
          else
            "You gave me -- I have no idea what to do with that."
        end
      end
    end
  end
end
