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
    # array of errors - elements which wasn't found: 1 - indicator, 2 - town
    errors = {'1' => [], '2' => []}
    # rows of description and total values for Ukraine
    table[:rows][0].each{|key, val|
      next if key == "towns"
      indicator_key = KeyIndicateMap::IndicatorKey.where(:name => key).first
      indicator_keys[key] = indicator_key

      if indicator_key
        if indicator_key['history'].nil? || indicator_key['history'].empty?
          attrs = {}
        else
          attrs = indicator_key['history']
        end
        attrs[year] = {} if attrs[year].nil?
        attrs[year]['description'] = val unless val.blank?
        attrs[year]['total'] = table[:rows][1][key] unless table[:rows][1][key].blank?
        indicator_key.update_attributes({'history' => attrs})
      else
        errors['1'].push(key)
      end

    }

    # rows for all other towns and regions
    table[:rows].each_with_index { |row, index|
      next if index < 2
      town = ::Town.any_of(:title => /#{row['towns'].strip}/i).first # case insensitive search of town or region
      errors['2'].push(row['towns']) unless town
      row.each{|key, val|
        next if key == "towns" || val.blank?
        indicator = KeyIndicateMap::Indicator.new
        indicator.value = val
        if town
          indicator.town = town
        else
          indicator['indicator_errors'] = {} if indicator['indicator_errors'].nil?
          indicator['indicator_errors']['2'] = row['towns']
        end
        if indicator_keys[key]
          indicator.key_indicate_map_indicator_key = indicator_keys[key]
        else
          indicator['indicator_errors'] = {} if indicator['indicator_errors'].nil?
          indicator['indicator_errors']['1'] = {}
          indicator['indicator_errors']['1']['key'] = key
          indicator['indicator_errors']['1']['description'] = table[:rows][0][key]['description']
          indicator['indicator_errors']['1']['total'] = table[:rows][1][key]['total']
        end
        indicator.key_indicate_map_indicator_file = self._id.to_s
        indicator.save
      }
    }

    errors

  end

end
