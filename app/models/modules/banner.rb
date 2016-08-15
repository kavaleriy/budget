class Modules::Banner
  include Mongoid::Document

  field :title, type: String
  field :order_banner, type: Integer
  field :publish_on, type: Mongoid::Boolean
end
