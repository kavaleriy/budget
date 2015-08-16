class KeyIndicateMap::IndicatorKey
  include Mongoid::Document

  # perform rake key_indicate_map:load task to load this model with data

  field :name, type: String
  field :unit, type: String
  field :group, type: String
  field :average_or_sum, type: String # to calculate total value for all Ukraine: average or sum
  field :integer_or_float, type: String # to make value integer or float

end
