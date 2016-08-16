class Modules::Banner
  include Mongoid::Document

  include Mongoid::Timestamps
  field :title, type: String
  field :order_banner, type: Integer
  field :publish_on, type: Boolean
  field :banner_url, type: String

  before_create :set_order_banner

  validates_presence_of  :title
  validates_presence_of  :banner_img, unless: :banner_url?
  validates_presence_of  :banner_url, unless: :banner_img?

  mount_uploader :banner_img, BannerImageUploader
  skip_callback :update, :store_previous_model_for_banner_img

  def self.get_publish_banners
    where(publish_on: true).order(order_banner: :desc)
  end

  def set_order_banner
    count = Modules::Banner.count
    self.order_banner = count + 1
  end
end
