class CalendarAction
  include Mongoid::Document

  ACTION_TYPE_FOLDING = 1
  ACTION_TYPE_ANALYSIS = 2
  ACTION_TYPE_DISCUSSION = 3
  ACTION_TYPE_EXECUTION = 4

  ACTION_TYPE_DISCUSSION_COLOR = '#0000FF'
  ACTION_TYPE_EXECUTION_COLOR = '#008800'
  ACTION_TYPE_ANALYSIS_COLOR = '#FF5D00'
  ACTION_TYPE_FOLDING_COLOR = '#FF0000'

  before_save :set_default_color

  field :holder, type: Integer
  field :title, type: String
  field :icon, type: String
  field :description, type: String
  field :text_color, type: String
  field :color, type: String
  field :action_type, type: Integer

  validates_presence_of :holder, message: I18n.t('errors.messages.empty')
  validates_presence_of :title, message: I18n.t('errors.messages.empty')

  scope :city_actions, lambda { where(holder: 1) }
  scope :people_actions, lambda { where(holder: 2) }


  def get_folding_type
    ACTION_TYPE_FOLDING
  end

  def get_analysis_type
    ACTION_TYPE_ANALYSIS
  end

  def get_discusion_type
    ACTION_TYPE_DISCUSSION
  end

  def get_execution_type
    ACTION_TYPE_EXECUTION
  end

  private
  def set_default_color
    if self.color.nil?
       case self.action_type
         when ACTION_TYPE_FOLDING then set_color(ACTION_TYPE_FOLDING_COLOR)
         when ACTION_TYPE_ANALYSIS then set_color(ACTION_TYPE_ANALYSIS_COLOR)
         when ACTION_TYPE_EXECUTION then set_color(ACTION_TYPE_EXECUTION_COLOR)
         when ACTION_TYPE_DISCUSSION then set_color(ACTION_TYPE_DISCUSSION_COLOR)
         else raise "undefined type"
       end
    end
  end

  def set_color(color)
    self.color = color
    self.text_color = color_invert(color)
  end
  def color_invert(color)
    color_code = color.gsub(/^#/, '')
    '#' + sprintf("%X", color_code.hex ^ 0xFFFFFF)
  end
    # attr_accessor :holder_string
  # after_initialize :do_after_initialize
  # def do_after_initialize
  #   self.holder_string =
  #       if self.holder == 1
  #         'Місто'
  #       else
  #         'Громада'
  #       end
  # end


end
