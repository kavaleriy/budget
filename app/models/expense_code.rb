class ExpenseCode
  include Mongoid::Document
  field :ktfk, type: String
  field :title, type: String
end
