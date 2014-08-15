class Event
  include Mongoid::Document

  embedded_in :calendar
  belongs_to  :calendar

  before_validation :do_before_validation

  field :holder, type: Integer
  field :title, type: String
  field :icon, type: String
  field :description, type: String
  field :starts_at, type: DateTime
  field :ends_at, type: DateTime
  field :all_day, type: Boolean
  field :color, type: String
  field :media, type: String

  attr_accessor :starts_at_string, :ends_at_string

  after_initialize :do_after_initialize


  def do_after_initialize
    self.starts_at_string = self.starts_at.strftime('%d/%m/%Y %H:%M') unless self.starts_at.nil?
    self.ends_at_string = self.ends_at.strftime('%d/%m/%Y %H:%M') unless self.ends_at.nil?
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
        :media => self.media,
        # :url => Rails.application.routes.url_helpers.event_path(id),
    }
  end
end
