class Calendar
  include Mongoid::Document

  embeds_many :events
end
