class HomeController < ApplicationController
  def index
  end

  def pie_data
    starts_at = Event.asc(:starts_at).limit(1).first.starts_at
    ends_at = Event.desc(:ends_at).limit(1).first.ends_at

    events = { e1: [], e2: [] }
    Event.where(:holder => 1).where(:ends_at => { '$ne' => nil}).asc(:starts_at).map { |i| events[:e1] << build_event_for_pie(i) }
    Event.where(:holder => 2).where(:ends_at => { '$ne' => nil}).asc(:starts_at).map { |i| events[:e2] << build_event_for_pie(i) }

    render json: { starts_at: starts_at.strftime('%d/%m/%Y'), ends_at: ends_at.strftime('%d/%m/%Y'), days: (ends_at - starts_at) / 3600 / 24 , events1: events[:e1], events2: events[:e2] }
  end

  def build_event_for_pie event
    days  = (event.ends_at - event.starts_at).to_i
    { label: event.title, desc: event.description, starts_at: event.starts_at.strftime('%d/%m/%Y'), ends_at: event.ends_at.strftime('%d/%m/%Y'), value: days, color: event.color, highlight: event.color }
  end

end
