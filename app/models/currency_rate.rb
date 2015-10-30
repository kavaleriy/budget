class CurrencyRate
  include Mongoid::Document

  default_scope lambda { order_by(:year => :desc) }

  embedded_in :currency, inverse_of: :rates

  field :year, type: Integer
  field :rate, type: Float
end
