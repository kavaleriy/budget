
class Calendar
  include Mongoid::Document

  field :author, type: String

  field :title, type: String
  field :description, type: String

  field :countdown_title, type: String
  field :countdown_event, type: Event

  embeds_many :events
  has_and_belongs_to_many :subscribers
  def to_xls(options = {})
    @this_calendar = Calendar.find(id)
    @events = @this_calendar.events
    @events.to_xls(
        :prepend =>[["Назва календаря", "Опис календаря"], [title, description], [], ["Події"], ["Назва", "Опис", "Дата початку","Дата завершення","Ініціатор"]],
        :only => [:title, :description, :starts_at,:ends_at, :holder_name],
        :header=>false,
        :column_width => [30,40,30,30,25,37],
        :column_height => 100,
        :word_wrap=> "normal")
   end
end
