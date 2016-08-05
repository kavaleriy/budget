class Modules::Partner
  include Mongoid::Document

  field :name, type: String
  field :order_logo, type: Integer
  field :publish_on, type: Mongoid::Boolean

  validates :name, :presence => true
  validates :logo, :presence => true, :on => :create

  mount_uploader :logo, PartnerLogoUploader
  skip_callback :update, :store_previous_model_for_logo

  def self.get_publish_partners
    where(publish_on: true).order(order_logo: :asc)
  end
end
