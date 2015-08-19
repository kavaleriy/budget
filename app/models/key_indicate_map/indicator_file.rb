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
  validates_uniqueness_of :year, message: 'За даний рік файл уже існує. Виберіть інший рік або видаліть старий файл.'

  def import table, year

    # once get all need indicator keys from database
    indicator_keys = {}
    # rows of description and total values for Ukraine
    table[:rows][0].each{|key, val|
      next if key == "towns"
      indicator_key = KeyIndicateMap::IndicatorKey.where(:name => key).first

      if indicator_key['history'].nil? || indicator_key['history'].empty?
        attrs = {}
      else
        attrs = indicator_key['history']
      end
      attrs[year] = {} if attrs[year].nil?
      attrs[year]['description'] = val unless val.blank?
      attrs[year]['total'] = table[:rows][1][key] unless table[:rows][1][key].blank?
      indicator_key.update_attributes({'history' => attrs})
      indicator_keys[key] = indicator_key
    }

    # rows for all other towns and regions
    table[:rows].each_with_index { |row, index|
      next if index < 2
      town = ::Town.any_of(:title => /#{row['towns']}/i).first # case insensitive search of town or region
      row.each{|key, val|
        next if key == "towns" || val.blank?
        indicator = KeyIndicateMap::Indicator.new
        indicator['value'] = val
        indicator.town = town
        indicator.key_indicate_map_indicator_file = self._id.to_s
        indicator.key_indicate_map_indicator_key = indicator_keys[key]
        indicator.save
      }
    }

  end

end
