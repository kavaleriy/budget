class RevenueRot
  include Mongoid::Document

  embedded_in :revenue
  belongs_to  :revenue

  field :kkd, type: String
  field :amount, type: Integer
end
