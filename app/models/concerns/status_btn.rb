module StatusBtn
  extend ActiveSupport::Concern

  module ClassMethods
    def status_btn(status)
      case status
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
