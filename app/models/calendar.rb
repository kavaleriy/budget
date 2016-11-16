class Calendar
  include Mongoid::Document

  before_save :change_active_status

  field :author, type: String
  field :town, type: String
  field :title, type: String
  field :description, type: String
  field :countdown_title, type: String
  field :countdown_event, type: Event
  field :import_file, type: String
  field :locale, type: String, default: 'uk'
  field :is_active, type: Boolean

  embeds_many :events
  has_and_belongs_to_many :subscribers
  belongs_to :town_model, class_name: 'Town'
  belongs_to :author_model, class_name: 'User'

  # Todo: Validates commented for successful run task 'rake refactor_town:calendar'
  # validates :title, :town_model, :author_model, presence: true

  # active status only for one calendar
  def change_active_status
    if is_active_changed? && is_active
      Calendar.where(:id.ne => self.id, town_model_id: self.town_model_id, is_active: true).update_all(is_active: false)
    end
  end

  # get active calendar if it is, otherwise any first
  def self.get_calendar_by_town(town)
    calendar = where(town_model_id: town, :is_active => true)
    if calendar.first.nil?
      calendar = where(town_model_id: town)
    end
    calendar.first
  end

  def self.visible_to user,locale
    self.get_calendars(user).get_calendars_by_locale(locale)
  end

  def import(path)
    require 'xls_parser'
    workbook = XlsParser.get_workbook(path)
    worksheet = workbook[0]

    unless worksheet.nil?
      table = XlsParser.get_table_hash(worksheet)

      table.first.delete_if{ |key, value| key == '_id'}

      self.update(table.first)
    end

    worksheet = workbook['Events']
    unless worksheet.nil?
      events_table = XlsParser.get_table_hash(worksheet)
      events_table.each do |new_event|
        event = self.events.new(new_event)
        event.save
      end
    end
  end


  def to_xls()
    require 'rubyXL'
    this_calendar = Calendar.find(id)
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'Calendar'
    i=0
    this_calendar.attributes.each do |attr_name, attr_value|
      if(attr_name != 'events')
        worksheet.add_cell(0, i, attr_name)
        worksheet.add_cell(1, i, attr_value)
      end
      i=i+1
    end

    worksheet = workbook.add_worksheet('Events')
    events = this_calendar.events
    # j=0
     event_attributes = ["_id", "holder", "title", "icon", "description",  "starts_at", "ends_at", "all_day", "text_color", "color"]
    # event_attributes.each do |attribute_name|
    #   worksheet.add_cell(0, j, attribute_name)
    #   j=j+1
    # end
    i = 0
    # event_attributes = ["title"]
    events.each do |event|
      j=0
      event_attributes.each do |attribute_name|
        if(i==0)
          worksheet.add_cell(i, j, attribute_name)
        else
          worksheet.add_cell(i, j, event.send(attribute_name))
        end
        j=j+1
      end
      i=i+1
    end
    workbook.stream.read

  end
  private

  def self.get_calendars_by_locale(locale)
    # this function return calendars by locale
    # get one params (locale is web-site locale)
    # if locale is nil set default locale
    # if locale is default locale
    # then return all calendars where locale is default locale or nil
    # else return all calendars where locale is params(locale)
    default_locale = 'uk'
    if locale.nil?
      locale = default_locale
    end

    if locale.eql? default_locale
      where(:locale.in => [locale,nil])
    else
      where(:locale => locale)
    end
  end

  def self.get_calendars(user)
    # this function return calendars visible from user
    # if user nil return calendars with empty author field
    # else if user is admin return all calendars
    # else return calendars where author is nil and any of user email or user town
    calendars = if user.nil?
                  self.where(:author => nil)
                elsif user.has_role? :admin
                  self.all
                else
                  # TODO!!!
                  self.where(:author => nil).any_of({:author => user.email},{:town => user.town}, {author_model: user})
                end
    calendars || self
  end

end
