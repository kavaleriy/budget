module Repairing::RepairsHelper
  def date_valid?(date)
    # date not blank and date not eql default date
    !date.blank? && !date.eql?(Date.new(1970,01,01))
  end

  def valid_status(field)
    if field.blank?
      'not-valid'
    end
  end

  def correct_edrpou(edrpou)
    edrpou.rjust(8, '0')
  end
end
