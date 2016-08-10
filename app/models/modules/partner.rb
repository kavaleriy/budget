class Modules::Partner
  include Mongoid::Document

  field :name, type: String
  field :order_logo, type: Integer
  field :publish_on, type: Mongoid::Boolean

  before_create :set_order_logo

  validates :name, :presence => true
  validates :logo, :presence => true, :on => :create

  mount_uploader :logo, PartnerLogoUploader
  skip_callback :update, :store_previous_model_for_logo

  def self.get_publish_partners
    where(publish_on: true).order(order_logo: :asc)
  end

  def set_order_logo
    count = Modules::Partner.count
    self.order_logo = count + 1
  end
end
