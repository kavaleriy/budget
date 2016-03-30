require 'carrierwave/mongoid'
class Modules::Slider

  include Mongoid::Document
  validates :text,:img, presence: true

  field :text, type: String
  field :sl_order, type:Integer

  mount_uploader :img, SliderUploader

  skip_callback :update, :store_previous_model_for_img

  def delete_image_file!
    self.remove_img!;
  end
end
