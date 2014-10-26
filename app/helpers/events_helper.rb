module EventsHelper
  def date_to_string(date)
    I18n.l(date, format: '%-d %B %Y %H:%M').gsub(/00:00/, '')
  end

  def holder_to_string(holder)
    if holder == 1
      'Місто'
    else
      'Громада'
    end
  end
end
