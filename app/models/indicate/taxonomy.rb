class Indicate::Taxonomy
  include Mongoid::Document

  scope :get_indicate_by_town, ->(town){ where(:town => town) }

  belongs_to :town, :class_name => 'Town'
  has_many :indicate_indicator_files, :class_name => 'Indicate::IndicatorFile', autosave: true, :dependent => :destroy

  def self.visible_to user
    if user.is_admin?
      self.all
    else
      self.get_indicate_by_town(user.town)
    end
  end

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
        # indicators[group][name][year] = {} if indicators[group][name][year].nil?
        # indicators[group][name][year]['comment'] = indicator['comment']
        # indicators[group][name][year]['value'] = indicator['value']
        # indicators[group][name][year]['id'] = indicator._id.to_s
        # indicators[group][name][year]['matching'] = indicator['matching']
        # indicators[group][name][year]['link'] = indicator['link']
        # indicators[group][name]['id'] = replace_space_indicator_chart_id(group, name)

        matching = indicator['matching']
        matching = 'fact' if matching.eql?('') || matching.nil?
        indicators[group][name][matching] = {} if indicators[group][name][matching].nil?
        indicators[group][name][matching][year] = {} if indicators[group][name][matching][year].nil?
        indicators[group][name][matching][year]['comment'] = indicator['comment']
        indicators[group][name][matching][year]['value'] = indicator['value']
        indicators[group][name][matching][year]['link'] = indicator['link']
        indicators[group][name]['id'] = replace_space_indicator_chart_id(group, name)
        puts(indicators[group][name]['id'])
      }
    }
    # binding.pry
    indicators
  end

  def replace_space_indicator_chart_id(str1, str2)
    string = "#{str1}_#{str2}"
    string.tr(', ','__')
  end

end
