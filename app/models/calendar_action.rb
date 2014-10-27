class CalendarAction
  include Mongoid::Document

  field :holder, type: Integer
  field :title, type: String
  field :icon, type: String
  field :description, type: String
  field :text_color, type: String
  field :color, type: String

  scope :city_actions, lambda { where(holder: 1) }
  scope :people_actions, lambda { where(holder: 2) }

  validates_presence_of :holder, message: I18n.t('errors.messages.empty')
  validates_presence_of :title, message: I18n.t('errors.messages.empty')

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
