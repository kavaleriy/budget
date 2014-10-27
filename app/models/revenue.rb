class Revenue
  include Mongoid::Document

  embeds_many :revenue_rots

  field :title, type: String
  field :file, type: String
end
