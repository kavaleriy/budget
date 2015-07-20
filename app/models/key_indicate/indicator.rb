class KeyIndicate::Indicator
  include Mongoid::Document

  field :key, type: String
  field :amount, type: String
  field :year, type: Integer
  field :description, type: String

  belongs_to :key_indicate_indicator_file, :class_name => 'KeyIndicate::IndicatorFile', autosave: true

end
