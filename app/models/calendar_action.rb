class CalendarAction
  include Mongoid::Document

  ACTION_TYPE_FOLDING = 1
  ACTION_TYPE_ANALYSIS = 2
  ACTION_TYPE_DISCUSSION = 3
  ACTION_TYPE_EXECUTION = 4

  field :holder, type: Integer
  field :title, type: String
  field :icon, type: String
  field :description, type: String
  field :text_color, type: String
  field :color, type: String
  field :action_type, type: Integer
  scope :city_actions, lambda { where(holder: 1) }
  scope :people_actions, lambda { where(holder: 2) }

  validates_presence_of :holder, message: I18n.t('errors.messages.empty')
  validates_presence_of :title, message: I18n.t('errors.messages.empty')

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
