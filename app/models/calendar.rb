class Calendar
  include Mongoid::Document
  field :dt_start, type: Date
  field :dt_end, type: String
  field :title, type: String
  field :body, type: String
end
