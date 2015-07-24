class KeyIndicate::Town
  include Mongoid::Document

  field :title, type: String

  has_many :key_indicate_indicator_files, :class_name => 'KeyIndicate::IndicatorFile', autosave: true, :dependent => :destroy
  has_and_belongs_to_many :key_indicate_town, :class_name => 'KeyIndicate::Town'

  def get_indicators
    indicators = {}
    self.key_indicate_indicator_files.each{|file|
      file.key_indicate_indicators.each{|indicator|
        key = indicator['key_indicator']
        year = indicator['year']
        indicators[year] = {} if indicators[year].nil?
        indicators[year][key] = {}
        indicators[year][key]['name'] = self.explanation[key]['indicator']
        indicators[year][key]['name'] += ", " + self.explanation[key]['unit'] unless self.explanation[key]['unit'].nil?
        indicators[year][key]['icon'] = self.explanation[key]['icon']
        indicators[year][key]['type'] = self.explanation[key]['type']
        indicators[year][key]['color'] = self.explanation[key]['color']
        indicators[year][key]['amount'] = indicator['amount']
        indicators[year][key]['description'] = indicator['description']
      }
    }
    indicators
  end

end
