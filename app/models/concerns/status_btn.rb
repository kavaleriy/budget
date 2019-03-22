module StatusBtn
  extend ActiveSupport::Concern

  module ClassMethods
    def status_btn(status)
      if status == 'оренда'
        'rent'
      elsif status == 'в користуванні'
        'occupied'
      else
        'free'
      end
    end
  end
end
