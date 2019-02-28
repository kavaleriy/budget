module StatusBtn
  extend ActiveSupport::Concern

  module ClassMethods
    def status_btn(status)
      case status.mb_chars.downcase.to_s
        when 'оренда'
          'rent'
        when 'в користуванні'
          'occupied'
        else
          'free'
      end
    end
  end
end
