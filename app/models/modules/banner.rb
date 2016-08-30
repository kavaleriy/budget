class Modules::Banner
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :order_banner, type: Integer
  field :publish_on, type: Boolean
  field :url, type: String

  scope :get_publish_banners, -> {where(publish_on: true)}

  before_create :set_order_banner

  validates_presence_of :title
  validates_presence_of :banner_img, on: :create

  mount_uploader :banner_img, BannerImageUploader
  skip_callback :update, :store_previous_model_for_banner_img

  def set_order_banner
    count = Modules::Banner.count
    self.order_banner = count + 1
  end
end
