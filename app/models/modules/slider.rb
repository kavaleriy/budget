class Modules::Slider
  include Mongoid::Document

  field :text, type: String
  field :sl_order, type:Integer
  field :img, type: String

end
