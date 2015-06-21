class Programs::Expences
  include Mongoid::Document

  field :year, type: Integer
  field :amount_plan, type: Integer
  field :amount_fact, type: Integer
  field :description, type: String

  belongs_to :programs_expences_file, :class_name => 'Programs::ExpencesFile', autosave: true
  belongs_to :programs_target_program, :class_name => 'Programs::TargetProgram', autosave: true



end
