class Programs::Program
  include Mongoid::Document
  field :title, type: String
  field :years, type: Hash
  has_many :sub_programs,class_name: 'Program::Program'

end
