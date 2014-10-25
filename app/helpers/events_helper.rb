module EventsHelper
  def date_to_string(date)
    I18n.l(date, format: '%-d %B %Y %H:%M').gsub(/00:00/, '')
  end
end
