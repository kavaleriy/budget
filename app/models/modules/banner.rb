class Modules::Banner
  include Mongoid::Document

  include Mongoid::Timestamps
  field :title, type: String
  field :order_banner, type: Integer
  field :publish_on, type: Mongoid::Boolean
  field :banner_url, type: String

  before_create :set_order_banner

  validates :title, :presence => true
  validates :banner_img, :presence => true, if: "banner_url.blank?"
  validates :banner_url, :presence => true, if: "banner_img.blank?"

  mount_uploader :banner_img, BannerImageUploader
  skip_callback :update, :store_previous_model_for_banner_img

  def set_order_banner
    count = Modules::Banner.count
    self.order_banner = count + 1
  end
end
