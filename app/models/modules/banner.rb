class Modules::Banner
  include Mongoid::Document

  field :title, type: String
  field :order_banner, type: Integer
  field :publish_on, type: Mongoid::Boolean
  field :banner_url, type: String

  mount_uploader :banner_img, BannerImageUploader
  skip_callback :update, :store_previous_model_for_banner_img
end
