class Programs::TargetProgram
  include Mongoid::Document

  field :kpkv, type: String      # program code
  field :kfkv, type: String      # functional code (branch)
  field :title, type: String
  field :author, type: String
  field :targets, type: String
  field :tasks, type: Array
  field :expected_results, type: Array
  field :participants, type: Array
  field :term_start, type: String
  field :term_end, type: String
  field :description, type: String

  belongs_to :programs_town, :class_name => 'Programs::Town', autosave: true

  validates :title, presence: true
  validates :kpkv, uniqueness: true

end
