class Indicate::Taxonomy
  include Mongoid::Document

  scope :get_indicate_by_town, ->(town){ where(:town => town) }
  # Get indicate_taxonomies by towns
  scope :by_towns, lambda { |towns| where(:town.in => towns.split(",")) }

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
        # indicators[group][name][year]['status'] = indicator['status']
        # indicators[group][name][year]['link'] = indicator['link']
        # indicators[group][name]['id'] = replace_space_indicator_chart_id(group, name)

        status = indicator['status']
        status = 'fact' if status.blank?
        indicators[group][name][status] = {} if indicators[group][name][status].nil?
        indicators[group][name][status][year] = {} if indicators[group][name][status][year].nil?
        indicators[group][name][status][year]['comment'] = indicator['comment']
        indicators[group][name][status][year]['value'] = indicator['value']
        indicators[group][name][status][year]['link'] = indicator['link']
        indicators[group][name]['id'] = replace_space_indicator_chart_id(group, name)
        indicators[group][name]['unit'] = indicator['unit'] || 'units'
      }
    }
    indicators
  end

  def replace_space_indicator_chart_id(str1, str2)
    # This function create id for one chart
    # '.tr()' replace comma and space to underscore
    return "#{str1}_#{str2}".tr(', .%','_')
  end

end
