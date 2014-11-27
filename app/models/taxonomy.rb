class Taxonomy
  include Mongoid::Document

  field :title, type: String
  field :columns, type: Hash

  # additional info
  field :rows_info, :type => Hash

  belongs_to_many :budget_files
end
