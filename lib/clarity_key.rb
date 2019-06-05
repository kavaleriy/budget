# module was created only for using in fill_db_from_prozorro.rake for API requests
module ClarityKey
  def area_title(area_title)
    case area_title
      when 'Вінницька область'
        return 'vn'
      when 'Волинська область'
        return 'volyn'
      when 'Дніпропетровська область'
        return 'dp'
      when 'Донецька область'
        return 'dn'
      when 'Житомирська область'
        return 'zt'
      when 'Закарпатська область'
        return 'uz'
      when 'Запорізька область'
        return 'zp'
      when 'Київська область'
        return 'kiev'
      when 'Кіровоградська область'
        return 'kr'
      when 'Луганська область'
        return 'lg'
      when 'Львівська область'
        return 'lviv'
      when 'Миколаївська область'
        return 'mk'
      when 'Одеська область'
        return 'od'
      when 'Полтавська область'
        return 'pl'
      when 'Рівненська область'
        return 'rv'
      when 'Сумська область'
        return 'sm'
      when 'Тернопільська область'
        return 'te'
      when 'Харківська область'
        return 'kh'
      when 'Херсонська область'
        return 'ks'
      when 'Хмельницька область'
        return 'km'
      when 'Черкаська область'
        return 'ck'
      when 'Чернігівська область'
        return 'cn'
      when 'Чернівецька область'
        return 'cv'
      when 'Івано-Франківська область'
        return 'if'
      else
        return nil
    end
  end
end
