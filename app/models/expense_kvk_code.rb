class ExpenseKvkCode
  include Mongoid::Document
  field :kvk, type: String
  field :title, type: String
end
