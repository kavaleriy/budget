namespace :fill_db_from_prozorro do



  desc 'Filling data base by API from clarity-project.info'
  task set_acount_number: :environment do
    # парсити джейсон по наявності назви місста у title
    # offset АПІ видає по 100 items, тому після перших 100 потрібно передавати offset += 100
    # prozorro_clarity_data(status='complete', region='vn', classification='45', offset=0) з external_API
    # ічувати і робити спроби якщо з першої не вийшло
    # сортувати по даті з 2018 року
    binding.pry
    repair_data = ExternalApi.prozorro_clarity_data('complete', 'vn', 45, 0)
    if repair_data['error']['code'].present? && repair_data['error']['code'] == 500

    end

  end
end
