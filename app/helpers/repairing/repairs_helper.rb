module Repairing::RepairsHelper
  def date_valid?(date)
    # date not blank and date not eql default date
    !date.blank? && !date.eql?(Date.new(1970,01,01))
  end

  def valid_status(repair, name_field)
    repair.valid?
    if repair.errors.messages.keys.include?(name_field)
      'not-valid'
    elsif
      ''
    end
  end
end
