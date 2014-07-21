class CalendarAction
  include Mongoid::Document

  field :title, type: String
  field :icon, type: String
  field :description, type: String
  field :color, type: String
  field :holder, type: Integer
end
