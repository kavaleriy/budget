class HomeController < ApplicationController
  def index
    @timeline_events = build_timeline
  end

  def pie_data
    starts_at = Event.asc(:starts_at).limit(1).first.starts_at
    ends_at = Event.desc(:ends_at).limit(1).first.ends_at

    events = { e1: [], e2: [] }
    Event.where(:holder => 1).where(:ends_at => { '$ne' => nil}).asc(:starts_at).map { |i| events[:e1] << build_event_for_pie(i) }
    Event.where(:holder => 2).where(:ends_at => { '$ne' => nil}).asc(:starts_at).map { |i| events[:e2] << build_event_for_pie(i) }

    render json: { starts_at: starts_at.strftime('%d/%m/%Y'), ends_at: ends_at.strftime('%d/%m/%Y'), days: (ends_at - starts_at) / 3600 / 24 , events1: events[:e1], events2: events[:e2] }
  end

  protected
    def build_event_for_pie event
      days  = (event.ends_at - event.starts_at).to_i
      { label: event.title, desc: event.description, starts_at: event.starts_at.strftime('%d/%m/%Y'), ends_at: event.ends_at.strftime('%d/%m/%Y'), value: days, color: event.color, highlight: event.color }
    end


  def build_timeline
    events = [ ]
    Event.all.map { |i|
      if i.ends_at
        action = i.ends_at > Date.today ? 'закінчиться: ' + i.ends_at.strftime('%d-%m-%Y') : 'закінчилась'
      else
        action = 'одноденна'
      end
      events << { holder: i.holder, dt: i.starts_at, action: action, title: i.title, description: i.description, icon: i.icon, color: i.color, all_day: i.all_day }
    }

    # today = DateTime.now.strftime('%d-%m-%Y')
    # events << { dt: today } unless events.any? {|e| e[:dt] == today }

    events.sort_by { |m| m[:dt] }.reverse!
  end


end
