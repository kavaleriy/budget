class Indicate::Indicator
  include Mongoid::Document

  field :name, type: String
  field :group, type: String
  field :comment, type: String
  field :value, type: String
  field :year, type: String

  belongs_to :indicate_indicator_file, :class_name => 'Indicate::IndicatorFile', autosave: true

end
