# include ClarityKey

namespace :fill_db_from_prozorro do

  require 'simple_xlsx'
  require 'clarity_key'
  include ClarityKey

  # REPAIR_DOC_TITLE = ['Виконавець',	'ЄДРПОУ виконавця',	'Адреса',	'Координати',	'Адреса1',	'Координати1',	'Розпорядник бюджетних коштів',
  #              'ЄДРПОУ розпорядника бюджетних коштів',	'Об\'єкт',	'Опис робіт',	'Вартість',	'Дата початку ремонту',
  #              'Дата закінчення ремонту',	'Гарантія',	'Додаткова інформація']
  REPAIR_DOC_TITLE = ['Розпорядник бюджетних коштів',	'ЄДРПОУ розпорядника бюджетних коштів',	'Назва об\'єкту',	'Адреса',	'Координати',	'Адреса1',	'Координати1',
               'Опис робіт',	'Вартість',	'Дата початку ремонту',	'Дата закінчення ремонту',	'Гарантія',
               'ID закупівлі',	'Виконавець',	'ЄДРПОУ виконавця', 'Додаткова інформація']
  CLASSIFICATION = 45
  STATUS = 'complete'
  CREATED_FROM = '01-01-2019'
  CREATED_TO = '01-05-2019'

  desc 'Filling data base by API from clarity-project.info'
  task set_acount_number: :environment do
    # парсити джейсон по наявності назви місста у title DONE!!!!!!!!!!!
    # offset АПІ видає по 100 items, тому після перших 100 потрібно передавати offset += 100 DONE!!!!!!!!!!!!
    # prozorro_clarity_data(status='complete', region='vn', classification='45', offset=0) з external_API DONE!!!!!!!!!!!!
    # ічувати і робити спроби якщо з першої не вийшло DONE!!!!!!!!!!!!!
    # repair_data = ExternalApi.prozorro_clarity_data('complete', 'vn', 45, 0) DONE!!!!!!!!!
    #
    #
    # .delete_if(&:blank?)

    # region Занести в масив і по всім регіонам проічувати

    regions = {}

    # створюємо хеш з авторизованими містами назва міста: :ключ області
    towns = authority_towns.reject { |c| c.title.empty? }
    towns.each do |town|
      region = ClarityKey::area_title(town.area_title)
      town_title = town.title.split(' ')
      if town_title.include?('район') || region == nil

      else
        regions[town.title] = region
      end
    end
    regions.each do |title, region|
      for_file_name = 0
      get_request = true
      offset = 0
      while get_request do
        # path = "https://clarity-project.info/api/tender.search?status=complete&region=vn&classification=45&offset=0&more_fields=edrs,items&created_from=01-01-2019&created_to=01-05-2019"
        path = "https://clarity-project.info/api/tender.search?status=#{STATUS}&region=#{region}&classification=#{CLASSIFICATION}&offset=#{offset}&more_fields=edrs,items&created_from=#{CREATED_FROM}&created_to=#{CREATED_TO}"

        res = repair_request(path)
        json_data = JSON.parse(res.body)

        array_all_files_data = []
        for_file_name += 1
        if json_data['tenders'].present?
          if json_data['tenders'].count < 100
            get_request = false
          end
          json_data.try(:[], 'tenders').each_with_index do |repair, index|
            # json_data['tenders'].try(:[], index).try(:[], 'more').try(:[], 'items').try(:[], 0).try(:[], 'delivery').try(:[], 'address') || '' щоб не валилось DONE!!!!!!!!!!!!
            # https://clarity-project.info/api/edr.info/"#{04326106}" Беремо ЄДРОПОУ замовника DONE!!!!!!!!
            address = json_data['tenders'].try(:[], index).try(:[], 'more').try(:[], 'items').try(:[], 0).try(:[], 'delivery').try(:[], 'address') || ''
            arr_title = address.split(' ').delete_if(&:blank?)
            if arr_title.include?("#{title},") || arr_title.include?("м.#{title},")
              path = "https://clarity-project.info/api/edr.info/#{repair['buyer_edr']}"
              res = repair_request(path)
              json_buyer = JSON.parse(res.body)

              path = "https://clarity-project.info/api/tender.ids?ids=#{repair.try(:[], 'id')}"
              res_purchase = repair_request(path)
              json_purchase = JSON.parse(res_purchase.body)

              budget_manager  = json_buyer.try(:[], 'name') || ''
              buyer_edr       = json_buyer.try(:[], 'edr_data').try(:[], 'edr') || ''
              object          = repair.try(:[], 'title') || ''
              repair_addres   = address
              coord           = '49.223164, 28.439736'
              repair_addres_1 = ''
              coord_1         = ''
              work            = json_data['tenders'].try(:[], index).try(:[], 'more').try(:[], 'items').try(:[], 0).try(:[], 'descr')
              value           = repair.try(:[], 'value').try(:[], 'amount')
              date_start      = ''
              date_end        = ''
              varanty         = ''
              purchase_id     = json_purchase.try(:[], 'list').try(:[], 0).try(:[], 'tender')
              performer_name  = repair.try(:[], 'more').try(:[], 'edrs').try(:[], 0).try(:[], 'edr_data').try(:[], 'short_name') || ''
              performer_edr   = repair.try(:[], 'more').try(:[], 'edrs').try(:[], 0).try(:[], 'edr') || ''
              addition_info   = 'Занесено з допомогою clarity API'

              # doc_data = [] масив даних для слоя DONE!!!!!!!!
              doc_data = [budget_manager, buyer_edr, object, repair_addres, coord, repair_addres_1, coord_1, work,
                          value, date_start, date_end, varanty, purchase_id, performer_name, performer_edr, addition_info]

              array_all_files_data << doc_data
            end
          end
          if array_all_files_data.present?
            # місто перевірити вибірку, по id

            town = Town.where(title: title)
            api_file(array_all_files_data, town, for_file_name)
          end
          # які коди присилає, коли закінчення вже.... або по даті дивитись, щоб плюсувати
          offset += 100
          puts "Пішли далі #{offset}"
        else
          get_request = false
          puts "Thanks for attention!"
        end
      end
    end
    puts "Thanks for attention! array is empty"
  end

  private
  # Створюємо файл
  def api_file(rows, town, index)
    SimpleXlsx::Serializer.new("repairing_#{town.first.title}_#{index}.xlsx") do |doc|
      doc.add_sheet('Лист1') do |sheet|
        # вставити REPAIR_DOC_TITLE DONE!!!!!!!!!!
        sheet.add_row(REPAIR_DOC_TITLE)

        rows.each do |row|
          sheet.add_row(row)
        end
      end
    end
    file_path           = Rails.root.join("repairing_#{town.first.title}_#{index}.xlsx")
    f = File.open(file_path, "r")
    repairing_category  = Repairing::Category.where(title: 'ремонт з заміною вікон')
    params = ActionController::Parameters.new({ title: 'API test',
                                                                 description: '',
                                                                 town: town.first.id,
                                                                 repairs_file: f,
                                                                 repairing_category: repairing_category.first.id,
                                                                 locale: 'uk',
                                                                 status: 'plan',
                                                                 year: '2018' })
    repairing_layer_params_task = params.permit(:title, :description, :town, :repairs_file, :repairing_category, :locale, :status, :year)

    # файл має бути через КаріерВаве завантажений

    @repairing_layer = Repairing::Layer.new(repairing_layer_params_task)
    @repairing_layer.repairing_category_id = repairing_category.first.id
    @repairing_layer.town_id = town.first.id

    user = User.where(name: 'admin')
    @repairing_layer.owner = user.first
    if @repairing_layer.save
      unless file_path.nil?
        Repairing::Repair.import(@repairing_layer, file_path, params[:child_category])
        Thread.new do
          @repairing_layer.repairs.each do |repair|
            repair.coordinates = RepairingGeocoder.calc_coordinates(repair.address, repair.address_to) if repair.coordinates.blank?
            repair.save(validate: false)
          end
        end
      end
    end
    f.close
    File.delete(file_path) if File.exist?(file_path)
  end

  # запит на АПІ
  def repair_request(path)
    uri = URI(path)
    retry_request(uri, 0.2)
  end

  # Спимо якщо немає відповіді і пробуємо ще
  def retry_request(uri, sleep_s)
    again = true
    sleeper = sleep_s
    res = nil

    while again do
      res = Net::HTTP.get_response(uri)
      if res.header.code != '200'
        sleep sleeper
      else
        # binding.pry
        break
      end
      sleeper = sleeper + sleep_s
      if sleeper > 0.8
        break
      end
      puts "sleeper: #{sleeper}"
    end
    return res
  end

  # Вибірка всіх авторизованих міст
  def authority_towns
    city_authority_users = User.all.map do |u|
      if u.has_any_role?([:city_authority, :central_authority, :municipal_enterprise, :state_enterprise])
        u.town_model_id
      end
    end
    # second we find all they towns and last add regular expression to all they towns
    Town.where(:_id.in => city_authority_users.compact).delete_if(&:blank?)
  end
end
