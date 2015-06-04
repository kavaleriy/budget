class Indicate::Taxonomy
  include Mongoid::Document

  before_save :generate_title

  field :title, type: String
  field :town, type: String

  has_many :indicate_indicator_files, :class_name => 'Indicate::IndicatorFile', autosave: true, :dependent => :destroy

  def get_indicators
    indicators = {}

    self.indicate_indicator_files.each{|file|
      file_indicators = file.get_indicators
      file_indicators.each{|indicator|
        group = indicator['group']
        name = indicator['indicator']
        year = indicator['year'].to_i
        indicators[group] = {} if indicators[group].nil?
        indicators[group][name] = {} if indicators[group][name].nil?
        indicators[group][name][year] = {} if indicators[group][name][year].nil?
        indicators[group][name][year]['comment'] = indicator['comment']
        indicators[group][name][year]['value'] = indicator['value']
        indicators[group][name][year]['id'] = indicator._id.to_s
      }
    }
    indicators
  end

  private

  def generate_title
    self.title = self.class if self.title.nil?
  end

end
