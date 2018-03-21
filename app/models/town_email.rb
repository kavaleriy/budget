# government emails
class TownEmail
  include Mongoid::Document
  OWNERS = %i[city_council local_deputy peoples_deputy state_audit_office]

  belongs_to :town, inverse_of: :emails

  field :email, type: String
  field :owner, type: String

  validates :email, format: Devise.email_regexp
end