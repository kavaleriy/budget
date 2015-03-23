class EventAttachment
  include Mongoid::Document

  embedded_in :event
  # belongs_to  :event

  field :name, type: String
  field :description, type: String

end
