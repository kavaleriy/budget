class Widgets::CalendarController < Widgets::WidgetsController
  include EventsHelper
  before_action :set_calendar

  def show
    @calendar = Calendar.find(params[:calendar_id])
      respond_to do |format|
        format.html {render 'widgets/calendar/calendar_box'}
      end

  end

  def pie_cycle
    @curr_town_event = @calendar.events.where(holder: 1, :starts_at.lte => Date.current).last
    @curr_people_event = @calendar.events.where(holder: 2, :starts_at.lte => Date.current).last
  end

  def timeline
  end

  def pie_data
    last_event_date = get_last_event_date || Time.now
    # last_event_date = @calendar.events.desc(:ends_at).limit(1).first.ends_at
    # @calendar.events.desc(:ends_at).limit(1).first.ends_at.strftime("%Y-1-1")

    starts_at = Date.new(last_event_date.year,01,01)
    ends_at = Date.new(last_event_date.year+1,01,01)
    # starts_at_old = '2016-01-01'.to_date #Event.asc(:starts_at).limit(1).first.starts_at.to_date
    # ends_at_old = '2017-01-01'.to_date #Event.desc(:ends_at).limit(1).first.ends_at.to_date
    events = { e1: [], e2: [] }

    events[:e1] = build_pie starts_at, ends_at, @calendar.events.event_timeline(1, starts_at, ends_at)
    events[:e2] = build_pie starts_at, ends_at, @calendar.events.event_timeline(2, starts_at, ends_at)

    render json: { starts_at: starts_at.strftime('%d/%m/%Y'), ends_at: ends_at.strftime('%d/%m/%Y'), days: (ends_at - starts_at) / 3600 / 24 , events1: events[:e1], events2: events[:e2] }
  end

  def timelinejs_data
    starts_at = Date.current.strftime('%Y,%m,%d') #Event.asc(:starts_at).limit(1).first.starts_at.to_date

    timeline = {
        'timeline' => {
            'uniqueid' => "#{@calendar.id}",
            'headline' => @calendar.title,
            'type' => 'default',
            'text' => @calendar.description,
            'startDate' => starts_at,
            'asset'=>
                {
                    'media'=>'http://www.ua.undp.org/content/dam/ukraine/img/povred/20130703sk9M3oCW3tUZg6D8_pzuOo_large.jpeg',
                    # 'credit'=>'credits',
                    # 'caption'=>'caption'
                },
            'date' => []
        }
    }

    @calendar.events.all.each { |e|
      media = e.holder == 1 ? { img: 'timeline-city.png', thumb: 'city.png' } : { img: 'timeline-people.png', thumb: 'timeline-people.png'}

    point = {}
    point['startDate'] = e.starts_at.strftime('%Y,%m,%d')
    point['endDate'] = e.ends_at.strftime('%Y,%m,%d') unless e.ends_at.nil?
    point['headline'] = "#{e.title}"
    point['uniqueid'] = "#{e.id}"
    # point['text'] = e.description
    point['asset'] =
        {
            'media' => "/assets/calendar/#{media[:img]}",
            'thumbnail' => "/assets/calendar/#{media[:thumb]}",
            #'credit'=>'credit',
            #'caption'=>'caption'
        }

    timeline['timeline']['date'] << point
    }

    render json: timeline

  end

  def get_parent_event
    starts_at = '2015-01-01'.to_date
    ends_at = '2016-01-01'.to_date
    event = @calendar.events.find(params[:event_id])
    events = @calendar.events.event_timeline(event.holder, starts_at, ends_at)
    render :json => {:parent_event => events.uniq{|e| [e.starts_at, e.ends_at-e.starts_at]}.select{|e| e.starts_at == event.starts_at && e.ends_at == event.ends_at}}
  end



  private

  def build_pie starts_at, ends_at, ev
    pie = [ { ends_at: starts_at, events: [] }]
    ev.uniq{|e| [e.starts_at, e.ends_at-e.starts_at]}
    .map { |e|
      cycle = pie.detect {|dt| dt[:ends_at] <= e[:starts_at]}
      if cycle.nil?
        new_ev = build_event_for_pie( { :title => '', :description => '', starts_at: starts_at, ends_at: e[:starts_at], color: 'rgba(230, 230, 230, .5)' } )
        cycle = { ends_at: e[:ends_at], events: [ new_ev ] }
        pie << cycle
      end
      cycle[:events] << build_event_for_pie( { :title => '', :description => '', starts_at: cycle[:ends_at], ends_at: e[:starts_at], color: 'rgba(230, 230, 230, .5)' } ) if cycle[:ends_at] < e[:starts_at]
      cycle[:events] << build_event_for_pie(e)
      cycle[:ends_at] = e[:ends_at]
    }
    pie.each { |p|
      if p[:ends_at] < ends_at
        p[:events] << build_event_for_pie( { :title => '', :description => '', starts_at: p[:ends_at], ends_at: ends_at, color: 'rgba(230, 230, 230, .5)' } )
      end
    }
    pie
  end

  def build_event_for_pie event
    days  = (event[:ends_at].to_date - event[:starts_at].to_date).to_i
    { id: event[:id].to_s, title: event[:title], icon: event[:icon], desc: event[:description], starts_at: event[:starts_at].strftime('%d/%m/%Y'), ends_at: event[:ends_at].strftime('%d/%m/%Y'), value: days, color: event[:color], text_color: event[:text_color], highlight: 'rgba(100,200,100,.3)' }
  end


  def build_timeline calendar_events
    events = [ ]
    calendar_events.all.map { |i|
      if i.ends_at
        action = i.ends_at > Date.today ? 'закінчиться: ' + i.ends_at.strftime('%d-%m-%Y') : 'закінчилась'
      else
        action = 'одноденна'
      end
      events << { id: i.id.to_s,  holder: i.holder, dt: i.starts_at, action: action, title: i.title, description: i.description, icon: i.icon, color: i.color, all_day: i.all_day }
    }

    events.sort_by { |m| m[:dt] }.reverse!
  end

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

  def get_last_event_date
    unless @calendar.events.empty?
      @calendar.events.where(:ends_at.ne =>  nil).desc(:ends_at).limit(1).first.ends_at
    end
  end

end
