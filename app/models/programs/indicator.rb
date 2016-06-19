class Programs::Indicator
  include Mongoid::Document

  EXPENSES_TYPE = 1
  PRODUCT_TYPE = 2
  EFECTIVE_TYPE = 3
  QUALITY_TYPE = 4

  field :title_program, type: String
  field :title,type: String
  field :group,type: String
  field :measurement_unit,type: String
  field :value,type: String
  belongs_to :target_program,class_name: 'Programs::TargetProgram'
end
