class KeyIndicateMap::IndicatorKey
  include Mongoid::Document

  # perform rake key_indicate_map:load task to load this model with data

  field :name, type: String
  field :unit, type: String
  field :group, type: String
  field :integer_or_float, type: String # to make value integer or float
  field :history, type: Hash # history per years

  has_many :key_indicate_map_indicators, :class_name => 'KeyIndicateMap::Indicator', autosave: true, :dependent => :destroy

  validates_uniqueness_of :name, message: 'Показник з такою назвою вже існує. Введіть іншу назву, або видаліть старий показник.'

end
