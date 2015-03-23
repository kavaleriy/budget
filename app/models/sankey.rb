class Sankey
  include Mongoid::Document
  #
  # field :year, type: String
  field :rot_file_id, type: String
  field :rov_file_id, type: String

  # validates_uniqueness_of :year, scope: [:budget_file_rot_fond, :budget_file_rov_fond]

end
