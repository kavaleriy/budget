class Subscriber
  include Mongoid::Document

  belongs_to :calendars

  field :email, type: String
  validates :email, presence: true
end
