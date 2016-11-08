class Indicate::IndicatorFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :description, type: String

  has_many :indicate_indicators, :class_name => 'Indicate::Indicator', autosave: true, :dependent => :destroy
  belongs_to :indicate_taxonomy, :class_name => 'Indicate::Taxonomy', autosave: true

  mount_uploader :indicate_file, IndicateUploader
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
      indicator = Indicate::Indicator.new
      row.each{|key, value|
        indicator[key] = value
      }
      indicator.indicate_indicator_file = self._id.to_s
      indicator.save
    }

  end

end
