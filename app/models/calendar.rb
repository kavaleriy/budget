class Calendar
  include Mongoid::Document

  field :title, type: String
  field :description, type: String

  field :countdown_title, type: String
  field :countdown_date, type: DateTime
  field :countdown_event, type: Event

  embeds_many :events
end
