class ExpenseRov
  include Mongoid::Document

  embedded_in :expense
  belongs_to  :expense

  field :kvk, type: String
  field :krk, type: String
  field :ktfk, type: String
  field :kekv, type: String
  field :amount, type: Integer
end
