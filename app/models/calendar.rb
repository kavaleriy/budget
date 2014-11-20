class Calendar
  include Mongoid::Document

  field :owner_email, type: String

  field :title, type: String
  field :description, type: String

  field :countdown_title, type: String
  field :countdown_event, type: Event

  embeds_many :events
  has_and_belongs_to_many :subscribers
end
