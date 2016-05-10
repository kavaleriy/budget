class Calendar
  include Mongoid::Document

  scope :get_calendar_by_town, ->(town){ where(:town => town) }

  field :author, type: String
  field :town, type: String
  field :title, type: String
  field :description, type: String
  field :countdown_title, type: String
  field :countdown_event, type: Event
  field :import_file, type: String
  field :is_test, type: Boolean
  embeds_many :events
  has_and_belongs_to_many :subscribers


  def self.visible_to user
    if user.is_admin?
      self.all
    else
      self.get_calendar_by_town(user.town)
    end
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
end
