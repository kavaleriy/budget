class TargetedPrograms::Indicator
  include Mongoid::Document
  field :title,type: String
  field :items,type: Array
  belongs_to :targeted_program,class_name: 'TargetedPrograms::Program'
end
