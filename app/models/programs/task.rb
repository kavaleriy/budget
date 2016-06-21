class Programs::Task
  include Mongoid::Document

  field :title,type: String
  field :general_fund, type: String
  field :special_fund, type: String
  field :group_num,type: String
  field :sum, type: String

end
