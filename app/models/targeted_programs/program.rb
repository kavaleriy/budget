class TargetedPrograms::Program
  include Mongoid::Document
  field :title, type: String
  field :years, type: Hash
  has_many :sub_programs,class_name: 'TargetedPrograms::Program',foreign_key: 'p_id'
  has_many :indicators,class_name: 'TargetedPrograms::Indicator'

  field :p_id,type: String

  scope :get_main_programs,-> {where(p_id: nil)}
end
