require 'carrierwave/mongoid'
class Modules::Slider
  include Mongoid::Document
  validates :text,:img, presence: true

  field :text, type: String
  field :sl_order, type:Integer

  mount_uploader :img, SliderUploader

end
