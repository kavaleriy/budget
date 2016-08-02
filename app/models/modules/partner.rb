class Modules::Partner
  include Mongoid::Document


  field :name, type: String
  field :order_logo, type: Integer
  field :publish_on, type: Mongoid::Boolean


  mount_uploader :logo, PartnerLogoUploader
end
