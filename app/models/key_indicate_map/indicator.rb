class KeyIndicateMap::Indicator
  include Mongoid::Document

  field :value, type: String

  belongs_to :key_indicate_map_indicator_file, :class_name => 'KeyIndicateMap::IndicatorFile', autosave: true
  belongs_to :key_indicate_map_indicator_key, :class_name => 'KeyIndicateMap::IndicatorKey', autosave: true
  belongs_to :town, :class_name => '::Town', autosave: true

end
