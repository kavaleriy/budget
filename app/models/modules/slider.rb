require 'carrierwave/mongoid'
class Modules::Slider
  include Mongoid::Document


  validates :text,:img, presence: true
  validates :sl_order, uniqueness: true
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  field :text, type: String
  field :sl_order, type:Integer

  mount_uploader :img, SliderUploader

  skip_callback :update, :store_previous_model_for_img

  def profile_geometry
    img = MiniMagick::Image.open(self.img.path)
    @geometry = {:width => img[:width], :height => img[:height] }
  end

  def delete_image_file!
    binding.pry
    self.remove_img!;
  end
end
