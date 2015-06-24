class Calendar
  include Mongoid::Document

  field :author, type: String

  field :title, type: String
  field :description, type: String

  field :countdown_title, type: String
  field :countdown_event, type: Event
  field :export_file, type: String
  embeds_many :events
  has_and_belongs_to_many :subscribers
  def to_xls()
    require 'rubyXL'
    # binding.pry
    this_calendar = Calendar.find(id)
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'Calendar'
    # binding.pry
    i=0
    this_calendar.attributes.each do |attr_name, attr_value|
      if(attr_name != 'events')
        worksheet.add_cell(0, i, attr_name)
        worksheet.add_cell(1, i, attr_value)
      end
      i=i+1
    end
    # worksheet.add_cell(0, 0, 'Title')
    # worksheet.add_cell(0, 1, 'Description')
    # worksheet.add_cell(1, 0, title)
    # worksheet.add_cell(1, 1, description)

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
