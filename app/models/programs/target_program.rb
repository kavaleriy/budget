class Programs::TargetProgram
  include Mongoid::Document

  field :title, type: String
  field :author, type: String
  field :targets, type: String
  field :term, type: Hash

  belongs_to :programs_town, :class_name => 'Programs::Town', autosave: true

  validates :title, presence: true

end
