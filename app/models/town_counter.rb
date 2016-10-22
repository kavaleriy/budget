class TownCounter
  include Mongoid::Document

  embedded_in :town, inverse_of: :counters

  field :citizens, type: Integer
  field :house_holdings, type: Integer
  field :square, type: Float
end