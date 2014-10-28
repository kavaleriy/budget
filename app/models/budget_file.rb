class BudgetFile
  include Mongoid::Document
  field :title, type: String
  field :file, type: String
end
