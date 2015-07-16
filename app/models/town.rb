class Town
  include Mongoid::Document

  default_scope lambda { order_by(:title => :asc) }

  field :title, type: String
  field :links, type: String

  require 'carrierwave/mongoid'

  mount_uploader :img, TownUploader
  skip_callback :update, :before, :store_previous_model_for_img

  has_many :documentation_documents, class_name: 'Documentation::Document'

  def to_s
    self.title
  end

  def self.columns
    self.fields.collect{|c| c[1]}
  end

end
