class Event
  include Mongoid::Document

  embedded_in :calendar
  belongs_to  :calendar

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
  field :color, type: String
  field :text_color, type: String

  before_validation :do_before_validation
  validates :holder, presence: true
  validates :title, presence: true
  validates :starts_at, presence: true


  attr_accessor :holder_text,
                :starts_at_string,
                :ends_at_string,
                :all_day_string
  after_initialize :do_after_initialize


  def do_after_initialize
    self.holder_text = self.holder == 1 ? 'Місто' : 'Громада'

    self.starts_at_string = I18n.l(self.starts_at, format: '%d/%m/%Y %H:%M').gsub(/00:00/, '') unless self.starts_at.nil?
    self.ends_at_string = I18n.l(self.ends_at, format: '%d/%m/%Y %H:%M').gsub(/00:00/, '') unless self.ends_at.nil?
    self.all_day_string = self.all_day ? 'так' : 'ні'
  end

  def do_before_validation
    self.starts_at = (self.starts_at_string.nil? or self.starts_at_string.empty?) ?
        "" :
        DateTime.parse(self.starts_at_string)

    self.ends_at = (self.ends_at_string.nil? or self.ends_at_string.empty?) ?
        "" :
        DateTime.parse(self.ends_at_string)

  end

  def as_json (options = {})
    e = {
        :id => self.id.to_s,
        :holder => holder,
        :title => self.title,
        :icon => self.icon,
        :description => self.description || "",
        :start => self.starts_at,
        :end => ends_at,
        :allDay => self.all_day,
        :color => self.color,
        :text_color => self.text_color,
    }
  end
end
