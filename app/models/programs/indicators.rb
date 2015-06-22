class Programs::Indicators
  include Mongoid::Document

  field :year, type: Integer
  field :group, type: String
  field :indicator, type: String
  field :amount_plan, type: Integer
  field :amount_fact, type: Integer
  field :unit, type: String
  field :description, type: String

  belongs_to :programs_indicator_file, :class_name => 'Programs::IndicatorFile', autosave: true
  belongs_to :programs_target_program, :class_name => 'Programs::TargetProgram', autosave: true



end
