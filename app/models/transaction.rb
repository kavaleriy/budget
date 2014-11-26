class Transaction
  include Mongoid::Document
  field :kvk, type: String
  field :kfk, type: String
  field :kekv, type: String
  field :amount, type: String
end
