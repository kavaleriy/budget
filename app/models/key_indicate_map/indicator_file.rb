class KeyIndicateMap::IndicatorFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :year, type: Integer
  field :description, type: String

  has_many :key_indicate_map_indicators, :class_name => 'KeyIndicateMap::Indicator', autosave: true, :dependent => :destroy

  mount_uploader :indicate_file, KeyIndicateMapUploader
  skip_callback :update, :before, :store_previous_model_for_indicate_file

  validates_presence_of :indicate_file, message: 'Потрібно вибрати Файл'

  def import table, year

    indicator_keys = {} # once get all need indicator keys from database
    table[:rows].each_with_index { |row, index|
      if index == 0 # row of description
        row.each{|key, val|
          if key != "towns"
            indicator_key = KeyIndicateMap::IndicatorKey.where(:name => key).first
            indicator_key['description'] = {} if indicator_key['description'].nil?
            indicator_key['description'][year] = val unless val.blank?
            indicator_key.save
            indicator_keys[key] = indicator_key
          end
        }
      else
        town = ::Town.any_of(:title => /#{row['towns']}/i).first # case insensitive search of town or region
        row.each{|key, val|
          if key != "towns"
            indicator = KeyIndicateMap::Indicator.new
            indicator['value'] = val
            indicator.town = town
            indicator.key_indicate_map_indicator_file = self._id.to_s
            indicator.key_indicate_map_indicator_key = indicator_keys[key]
            indicator.save
          end
        }
      end
    }

  end

end
