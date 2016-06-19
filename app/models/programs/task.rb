class Programs::Task
  include Mongoid::Document

  field :title,type: String
  field :general_sum, type: String
  field :special_sum, type: String
  field :group_num,type: String
  field :sum, type: String

end
