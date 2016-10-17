module EventsHelper
  def date_to_string(date)
    I18n.l(date, format: '%-d %B %Y %H:%M').gsub(/00:00/, '')
  end

  def holder_to_string(holder)
    if holder == 1
      # t('eventowner_select.town')
      image_tag("calendar/city.png")
    else
      # t('eventowner_select.community')
      image_tag("calendar/people.png")
    end
  end
end
