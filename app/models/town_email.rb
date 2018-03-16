class TownEmail
  include Mongoid::Document

  embedded_in :town, inverse_of: :emails

  # government emails
  field :city_council, type: String
  field :local_deputy, type: String
  field :peoples_deputy, type: String
  field :state_audit_office, type: String
end