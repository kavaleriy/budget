class Event
  include Mongoid::Document

  scope :between, lambda {|start_time, end_time|
    {:conditions => ["? < starts_at < ?", Event.format_date(start_time), Event.format_date(end_time)] }
  }

  field :title, type: String
  field :description, type: String
  field :starts_at, type: DateTime
  field :ends_at, type: DateTime
  field :all_day, type: String
  field :color, type: String

  def as_json(options = {})
    e = {
        :id => self.id.to_s,
        :title => self.title,
        :description => self.description || "",
        :start => self.starts_at,
        :end => self.ends_at,
        :allDay => self.all_day || '',
        :color => self.color,
        # :url => Rails.application.routes.url_helpers.event_path(id),
    }
  end
end
