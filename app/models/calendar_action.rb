class CalendarAction
  include Mongoid::Document

  field :title, type: String
  field :icon, type: String
  field :description, type: String
  field :color, type: String
  field :holder, type: Integer

  attr_accessor :holder_string

  after_initialize :do_after_initialize


  def do_after_initialize
    self.holder_string =
        if self.holder == 1
          'Місто'
        else
          'Громада'
        end
  end


end
