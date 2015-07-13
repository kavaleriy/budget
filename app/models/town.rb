class Town
  include Mongoid::Document

  field :title, type: String

  require 'carrierwave/mongoid'

  mount_uploader :img, TownUploader
  skip_callback :update, :before, :store_previous_model_for_img

  has_many :document_category, class_name: 'Documentation::Category'

  def to_s
    self.title
  end

  def self.columns
    self.fields.collect{|c| c[1]}
  end

end
