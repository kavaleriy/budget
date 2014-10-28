class Expense < BudgetFile
  include Mongoid::Document

  embeds_many :expense_rovs
end

