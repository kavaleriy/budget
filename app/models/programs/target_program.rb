class Programs::TargetProgram
  include Mongoid::Document

  field :title, type: String
  field :town, type: String
  field :author, type: String
  field :target, type: String

  validates :title, presence: true

end
