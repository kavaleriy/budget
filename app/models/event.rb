class Event
  include Mongoid::Document

  embedded_in :calendar
  # belongs_to  :calendar

  scope :event_timeline, lambda { |holder, starts_at, ends_at| where(:holder => holder, :starts_at.gte => starts_at, :ends_at.lte => ends_at).where(:ends_at => { '$ne' => nil}).asc(:starts_at) }

  scope :current_event, lambda { |holder| where(:holder => holder, :starts_at.lt => Date.current, :ends_at.gt => Date.current).desc(:starts_at).limit(1) }
  scope :countdown_events, lambda { where(:ends_at.gt => Date.current).desc(:starts_at) }


  field :holder, type: Integer
  field :title, type: String
  field :icon, type: String
  field :description, type: String
  field :starts_at, type: DateTime
  field :ends_at, type: DateTime
  field :all_day, type: Boolean
  field :text_color, type: String
  field :color, type: String
  field :countdown_file, type: File

  embeds_many :event_attachments

  validates :holder, presence: true
  validates :title, presence: true
  validates :starts_at, presence: true

  def as_json (options = {})
    e = {
        :id => self.id.to_s,
        :holder => holder,
        :title => self.title,
        :icon => self.icon,
        :description => self.description || "",
        :start => self.starts_at,
        :end => self.ends_at,
        :allDay => self.all_day,
        :text_color => self.text_color,
        :color => self.color,
    }
  end

  def holder_name
    if holder == 1
      holder = "Місто"
    else holder = "Громада"
    end

  end

end
