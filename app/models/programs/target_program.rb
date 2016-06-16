class Programs::TargetProgram
  include Mongoid::Document
  field :title, type: String
  field :years, type: Hash
  has_many :sub_programs,class_name: 'Programs::TargetProgram',foreign_key: 'p_id'
  has_many :indicators,class_name: 'Programs::Indicator'

  field :p_id,type: String

  scope :get_main_programs,-> {where(p_id: nil)}
end
