require 'carrierwave/mongoid'
class Modules::Slider
  include Mongoid::Document

  after_update :reprocess_image, :if => :cropping?

  validates :text, presence: true
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

  def cropping?
    !crop_x.blank? and !crop_y.blank? and !crop_w.blank? and !crop_h.blank?
  end

  def delete_image_file!
    self.remove_img!;
  end

  private

  def reprocess_image
    img = MiniMagick::Image.open(self.img.path)
    crop_params = "#{crop_w}x#{crop_h}+#{crop_x}+#{crop_y}"
    img.crop(crop_params)
    img.write(self.img.slider.path)
  end

end
