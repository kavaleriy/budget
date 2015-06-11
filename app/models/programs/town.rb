class Programs::Town
  include Mongoid::Document

  field :name, type: String

  has_many :programs_target_programs, :class_name => 'Programs::TargetProgram', autosave: true, :dependent => :destroy

end
