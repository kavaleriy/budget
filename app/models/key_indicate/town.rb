class KeyIndicate::Town
  include Mongoid::Document

  belongs_to :town, :class_name => 'Town'
  has_many :key_indicate_indicator_files, :class_name => 'KeyIndicate::IndicatorFile', autosave: true, :dependent => :destroy

  def get_indicators year
    indicators = {}
    self.key_indicate_indicator_files.each{|file|
      file.key_indicate_indicators.each{|indicator|
        if indicator['year'] == year
          key = indicator['key_indicator']
          indicators[key] = {}
          indicators[key]['amount'] = indicator['amount']
          indicators[key]['description'] = indicator['description']
        end
      }
    }
    indicators
  end

end
