class Sankey
  include Mongoid::Document

  field :rot_file_id, type: String
  field :rov_file_id, type: String

  validates :rot_file_id, uniqueness: { scope: :rov_file_id, message: "Така візуалізація вже існує" }
end
