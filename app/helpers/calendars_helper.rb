module CalendarsHelper

  def get_countdown_event calendar
    @calendar.events.where(:id => @calendar.countdown_event).first if calendar.countdown_event
  end

  def get_current_event event
    return {} if event.nil? || (event.ends_at.to_date - event.starts_at.to_date) == 0
    percent = 100 * (Date.current - event.starts_at.to_date).to_i / (event.ends_at.to_date - event.starts_at.to_date).to_i
    { event: event, title: event.title, holder_text: holder_to_string(event.holder), percent: percent}
  end

end
