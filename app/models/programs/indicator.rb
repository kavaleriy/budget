class Programs::Indicator
  include Mongoid::Document

  EXPENSES_TYPE = 1
  PRODUCT_TYPE = 2
  EFECTIVE_TYPE = 3
  QUALITY_TYPE = 4

  field :title,type: String
  field :items,type: Array
  belongs_to :targeted_program,class_name: 'Programs::TargetProgram'
end
