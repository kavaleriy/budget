class KeyIndicate::IndicatorFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :description, type: String

  has_many :key_indicate_indicators, :class_name => 'KeyIndicate::Indicator', autosave: true, :dependent => :destroy
  belongs_to :key_indicate_town, :class_name => 'KeyIndicate::Town', autosave: true

  mount_uploader :indicate_file, KeyIndicateUploader
  skip_callback :update, :before, :store_previous_model_for_indicate_file

  validates_presence_of :indicate_file, message: 'Потрібно вибрати Файл'

  def get_indicators
    indicators = []
    self.indicate_indicators.each{|indicator|
      indicators.push(indicator)
    }
    indicators
  end

  def import table
    table[:rows].each{|row|
      indicator = KeyIndicate::Indicator.new
      row.each{|key, value|
        if key == 'key_indicator'
          if value.length > 1 && value.to_i != 0
            indicator[key] = value.to_i.to_s.rjust(3,'0')
          else
            k = KeyIndicate::DictionaryKey.where(:indicator => value).first
            if k
              indicator[key] = k['key']
            else
              indicator[key] = value
            end
          end
        else
          indicator[key] = value
        end
      }
      indicator.key_indicate_indicator_file = self._id.to_s
      indicator.save
    }

  end

end
