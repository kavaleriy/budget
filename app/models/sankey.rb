class Sankey
  include Mongoid::Document

  scope :owned_by, lambda { |owner| where(:owner => owner) }

  field :title, type: String
  field :owner, type: String
  
  field :rot_file_id, type: String
  field :rov_file_id, type: String

  validates :rot_file_id, uniqueness: { scope: :rov_file_id, message: "Така візуалізація вже існує" }
end
