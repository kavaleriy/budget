class ExpenseEkvCode
  include Mongoid::Document
  field :ekv, type: String
  field :title, type: String
end
